CREATE TYPE severity_values AS ENUM ('MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE social_platform_values AS ENUM ('TWITTER', 'FACEBOOK', 'TIKTOK', 'REDDIT');
CREATE TYPE spread_velocity_indicator_values AS ENUM ('STEADY', 'GROWING', 'SPREADING_FAST');
CREATE TYPE review_status_values AS ENUM ('NEEDS_REVIEW', 'DISMISSED', 'CONFIRMED_MISINFORMATION', 'CORRECTION_PUBLISHED');

CREATE TABLE incidents (
    id TEXT PRIMARY KEY,
    name TEXT,
    is_active BOOLEAN
);

CREATE TABLE narrative_clusters (
    id TEXT PRIMARY KEY,
    summary TEXT,
    incident_id TEXT REFERENCES incidents(id),
    spread_status spread_velocity_indicator_values,
    review_status review_status_values
);

CREATE TABLE posts (
    id TEXT PRIMARY KEY,
    author_name TEXT,
    platform social_platform_values,
    content TEXT,
    ts TIMESTAMPTZ,
    share_count BIGINT,
    post_url TEXT,
    misinformation_risk_score
        NUMERIC(2, 1) NOT NULL
        CHECK (misinformation_risk_score >= 0.0 AND misinformation_risk_score <= 1.0),
    severity severity_values GENERATED ALWAYS AS (
        CASE
            WHEN misinformation_risk_score >= 0.8 THEN 'CRITICAL'::severity_values
            WHEN misinformation_risk_score >= 0.5 THEN 'HIGH'::severity_values
            ELSE 'MEDIUM'::severity_values
        END
    ) STORED
);

CREATE TABLE narrative_cluster_posts (
    cluster_id TEXT REFERENCES narrative_clusters(id) ON DELETE CASCADE,
    post_id TEXT REFERENCES posts(id) ON DELETE CASCADE,
    PRIMARY KEY (cluster_id, post_id)
);

CREATE INDEX ON narrative_clusters (incident_id);
CREATE INDEX ON narrative_cluster_posts (post_id);

CREATE VIEW narrative_cluster_objects AS
SELECT
    nc.id AS narrative_id,
    nc.summary AS narrative_summary,
    nc.incident_id AS incident_id,
    i.name AS incident_name,
    max(p.severity) AS severity,
    array_agg(p.id ORDER BY p.ts) FILTER (WHERE p.id IS NOT NULL) AS post_ids,
    count(p.id) AS post_count,
    COALESCE(sum(p.share_count), 0) AS combined_shares,
    nc.spread_status AS spread_status,
    min(p.ts) AS timestamp_earliest,
    max(p.ts) AS timestamp_latest,
    array_agg(DISTINCT p.platform) FILTER (WHERE p.platform IS NOT NULL) AS platforms,
    nc.review_status AS review_status
FROM narrative_clusters nc
LEFT JOIN incidents i ON nc.incident_id = i.id
LEFT JOIN narrative_cluster_posts ncp ON ncp.cluster_id = nc.id
LEFT JOIN posts p ON p.id = ncp.post_id
GROUP BY nc.id, nc.summary, nc.incident_id, i.name;

CREATE VIEW active_incident_objects AS
SELECT
    i.id AS incident_id,
    i.name AS incident_name,
    count(nco.narrative_id) AS total_flags,
    jsonb_build_object(
        'critical', count(*) FILTER (WHERE nco.severity = 'CRITICAL'),
        'high', count(*) FILTER (WHERE nco.severity = 'HIGH'),
        'medium', count(*) FILTER (WHERE nco.severity = 'MEDIUM')
    ) AS severity_breakdown,
    (array_agg(nco.narrative_summary
               ORDER BY nco.severity DESC NULLS LAST,
                        nco.combined_shares DESC NULLS LAST)
    )[1] AS top_threat
FROM incidents i 
LEFT JOIN narrative_cluster_objects nco ON nco.incident_id = i.id
WHERE i.is_active = true
GROUP BY i.id, i.name;

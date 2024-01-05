WITH StreamerStats AS (
    SELECT
        cs.streamer_id,
        COUNT(*) AS total_streams,
        CEIL(AVG(cs.duration)) AS avg_duration
    FROM
        completed_streams cs
    GROUP BY
        cs.streamer_id
),
ViewerStats AS (
    SELECT
        cs.streamer_id,
        COUNT(DISTINCT v.id) AS total_viewers,
        COUNT(DISTINCT CASE WHEN v.duration > 30 THEN v.id END) AS uniq_viewers_gt_30min,
        COUNT(DISTINCT CASE WHEN v.duration <= 30 THEN v.id END) AS uniq_viewers_lte_30min
    FROM
        completed_streams cs
    LEFT JOIN
        viewers v ON cs.id = v.stream_id
    GROUP BY
        cs.streamer_id
)
SELECT
    s.username AS Username,
    COALESCE(ss.total_streams, 0) AS Total_streams,
    COALESCE(ss.avg_duration, 0) AS Avg_stream_duration,
    COALESCE(vs.total_viewers, 0) AS Total_viewers,
    COALESCE(vs.uniq_viewers_gt_30min, 0) AS Uniq_viewers_gt_30min,
    COALESCE(vs.uniq_viewers_lte_30min, 0) AS Uniq_viewers_tte_30min
FROM
    streamers s
LEFT JOIN
    StreamerStats ss ON s.id = ss.streamer_id
LEFT JOIN
    ViewerStats vs ON s.id = vs.streamer_id
ORDER BY
    Username;

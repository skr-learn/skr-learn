WITH StreamerStreams AS (
    SELECT
        s.username AS username,
        COUNT(*) AS total_streams
    FROM
        streamers s
    LEFT JOIN
        completed_streams cs ON s.id = cs.streamer_id
    GROUP BY
        s.username
),
StreamerAvgStreamDuration AS (
    SELECT
        s.username AS username,
        CEIL(AVG(cs.duration)) AS avg_stream_duration
    FROM
        streamers s
    LEFT JOIN
        completed_streams cs ON s.id = cs.streamer_id
    GROUP BY
        s.username
),
StreamerTotalViewers AS (
    SELECT
        s.username AS username,
        COUNT(*) AS total_viewers
    FROM
        streamers s
    LEFT JOIN
        completed_streams cs ON s.id = cs.streamer_id
    LEFT JOIN
        viewers v ON cs.id = v.stream_id
    GROUP BY
        s.username
),
StreamerUniqViewersGt30Min AS (
    SELECT
        s.username AS username,
        COUNT(DISTINCT v.id) AS uniq_viewers_gt_30min
    FROM
        streamers s
    LEFT JOIN
        completed_streams cs ON s.id = cs.streamer_id
    LEFT JOIN
        viewers v ON cs.id = v.stream_id
    WHERE
        v.duration > 1800 
    GROUP BY
        s.username
),
StreamerUniqViewersLte30Min AS (
    SELECT
        s.username AS username,
        COUNT(DISTINCT v.id) AS uniq_viewers_lte_30min
    FROM
        streamers s
    LEFT JOIN
        completed_streams cs ON s.id = cs.streamer_id
    LEFT JOIN
        viewers v ON cs.id = v.stream_id
    WHERE
        v.duration <= 1800 
    GROUP BY
        s.username
)
SELECT
    ss.username AS username,
    COALESCE(ss.total_streams, 0) AS total_streams,
    COALESCE(asd.avg_stream_duration, 0) AS avg_stream_duration,
    COALESCE(stv.total_viewers, 0) AS total_viewers,
    COALESCE(sugt30.uniq_viewers_gt_30min, 0) AS uniq_viewers_gt_30min,
    COALESCE(sult30.uniq_viewers_lte_30min, 0) AS uniq_viewers_lte_30min
FROM
    StreamerStreams ss
LEFT JOIN
    StreamerAvgStreamDuration asd ON ss.username = asd.username
LEFT JOIN
    StreamerTotalViewers stv ON ss.username = stv.username
LEFT JOIN
    StreamerUniqViewersGt30Min sugt30 ON ss.username = sugt30.username
LEFT JOIN
    StreamerUniqViewersLte30Min sult30 ON ss.username = sult30.username
ORDER BY
    ss.username ASC;

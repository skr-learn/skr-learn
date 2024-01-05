WITH StreamerTotalStreams AS (
    SELECT
        streamer_id,
        COUNT(*) AS total_streams
    FROM
        completed_streams
    GROUP BY
        streamer_id
),
StreamerAvgStreamDuration AS (
    SELECT
        streamer_id,
        AVG(duration) AS avg_duration
    FROM
        completed_streams
    GROUP BY
        streamer_id
),
StreamerTotalViewers AS (
    SELECT
        streamer_id,
        COUNT(*) AS total_viewers
    FROM
        viewers
    GROUP BY
        streamer_id
),
StreamerUniqViewersGt30Min AS (
    SELECT
        streamer_id,
        COUNT(DISTINCT v.id) AS uniq_viewers_gt_30
    FROM
        viewers v
    WHERE
        v.duration > 30
    GROUP BY
        streamer_id
),
StreamerUniqViewersLte30Min AS (
    SELECT
        streamer_id,
        COUNT(DISTINCT v.id) AS uniq_viewers_lte_30
    FROM
        viewers v
    WHERE
        v.duration <= 30
    GROUP BY
        streamer_id
)
SELECT
    s.username AS streamer_username,
    COALESCE(ts.total_streams, 0) AS total_streams,
    COALESCE(avg_stream_duration.avg_duration, 0) AS avg_stream_duration,
    COALESCE(total_viewers.total_viewers, 0) AS total_viewers,
    COALESCE(uniq_viewers_gt_30min.uniq_viewers_gt_30, 0) AS uniq_viewers_gt_30min,
    COALESCE(uniq_viewers_lte_30min.uniq_viewers_lte_30, 0) AS uniq_viewers_lte_30min
FROM
    streamers s
LEFT JOIN
    StreamerTotalStreams ts ON s.id = ts.streamer_id
LEFT JOIN
    StreamerAvgStreamDuration avg_stream_duration ON s.id = avg_stream_duration.streamer_id
LEFT JOIN
    StreamerTotalViewers total_viewers ON s.id = total_viewers.streamer_id
LEFT JOIN
    StreamerUniqViewersGt30Min uniq_viewers_gt_30min ON s.id = uniq_viewers_gt_30min.streamer_id
LEFT JOIN
    StreamerUniqViewersLte30Min uniq_viewers_lte_30min ON s.id = uniq_viewers_lte_30min.streamer_id;

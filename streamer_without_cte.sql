SELECT
    s.username AS username,
    COUNT(s.stream_id) AS total_streams,
    AVG(s.stream_duration) AS avg_stream_duration,
    SUM(v.total_viewers) AS total_viewers
FROM
    Streams s
LEFT JOIN
    (
        SELECT
            stream_id,
            COUNT(viewer_id) AS total_viewers
        FROM
            Viewers
        GROUP BY
            stream_id
    ) v ON s.stream_id = v.stream_id
GROUP BY
    s.username;

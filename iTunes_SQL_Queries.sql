CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(100),
    reports_to INT,
	levels VARCHAR(20),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(100)
);
SELECT * FROM EMPLOYEE


CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(200)
);

CREATE TABLE albums (
    album_id INT PRIMARY KEY,
    title VARCHAR(200),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);
CREATE TABLE genres (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE media_types (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE tracks (
    track_id INT PRIMARY KEY,
    name VARCHAR(200),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(200),
    milliseconds INT,
    bytes INT,
    unit_price NUMERIC(10,2),
    FOREIGN KEY (album_id) REFERENCES albums(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date TIMESTAMP,
    billing_address VARCHAR(200),
    billing_city VARCHAR(50),
    billing_state VARCHAR(50),
    billing_country VARCHAR(50),
    billing_postal_code VARCHAR(20),
    total NUMERIC(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE invoice_items (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price NUMERIC(10,2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);
CREATE TABLE playlists (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(200)
);
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);


SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM
    information_schema.table_constraints tc
JOIN
    information_schema.key_column_usage kcu
ON
    tc.constraint_name = kcu.constraint_name
WHERE
    tc.table_name = 'customers';
	
	SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM
    information_schema.table_constraints tc
JOIN
    information_schema.key_column_usage kcu
ON
    tc.constraint_name = kcu.constraint_name
WHERE
    tc.table_name = 'invoices';

	SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM
    information_schema.table_constraints tc
JOIN
    information_schema.key_column_usage kcu
ON
    tc.constraint_name = kcu.constraint_name
WHERE
    tc.table_name = 'invoice_items';

SELECT ROUND(AVG(total), 2) AS avg_invoice_value
FROM invoices;

SELECT 
    ROUND(SUM(total) / COUNT(DISTINCT customer_id), 2) 
    AS avg_revenue_per_customer
FROM invoices;

SELECT 
    customer_id,
    COUNT(invoice_id) AS purchase_count
FROM invoices
GROUP BY customer_id
ORDER BY purchase_count DESC;

SELECT 
    CASE 
        WHEN COUNT(invoice_id) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM invoices
GROUP BY customer_id;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customers c
JOIN invoices i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

SELECT 
    ROUND(SUM(total_spent),2) AS top5_total
FROM (
    SELECT 
        SUM(i.total) AS total_spent
    FROM customers c
    JOIN invoices i 
    ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
    ORDER BY total_spent DESC
    LIMIT 5
) sub;

SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity),2) AS total_revenue
FROM invoice_items il
JOIN tracks t ON il.track_id = t.track_id
JOIN genres g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_revenue DESC
LIMIT 5;

SELECT 
    t.name AS track_name,
    g.name AS genre,
    SUM(il.quantity) AS total_sales
FROM invoice_items il
JOIN tracks t ON il.track_id = t.track_id
JOIN genres g ON t.genre_id = g.genre_id
GROUP BY t.name, g.name
ORDER BY total_sales DESC
LIMIT 5;

SELECT 
    billing_country,
    ROUND(SUM(total),2) AS total_revenue
FROM invoices
GROUP BY billing_country
ORDER BY total_revenue DESC;

SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(total),2) AS monthly_revenue
FROM invoices
GROUP BY month
ORDER BY month;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total),2) AS total_spent,
    RANK() OVER (ORDER BY SUM(i.total) DESC) AS revenue_rank
FROM customers c
JOIN invoices i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY revenue_rank;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total),2) AS total_spent,
    DENSE_RANK() OVER (ORDER BY SUM(i.total) DESC) AS dense_rank
FROM customers c
JOIN invoices i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY dense_rank;

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(i.total) AS total_spent
    FROM customers c
    JOIN invoices i 
    ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)

SELECT *,
    CASE 
    WHEN total_spent >= 100 THEN 'High Value'
    WHEN total_spent >= 50 THEN 'Medium Value'
    ELSE 'Low Value'
    END AS customer_segment
FROM customer_spending
ORDER BY total_spent DESC;

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        SUM(i.total) AS total_spent
    FROM customers c
    JOIN invoices i 
    ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)

SELECT 
    CASE 
        WHEN total_spent >= 100 THEN 'High Value'
        WHEN total_spent >= 50 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_spending
GROUP BY customer_segment;


SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    ROUND(SUM(total), 2) AS total_revenue
FROM invoices
GROUP BY EXTRACT(YEAR FROM invoice_date)
ORDER BY year;


SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    ROUND(SUM(total), 2) AS monthly_revenue
FROM invoices
GROUP BY year, month
ORDER BY year, month;

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(total) AS revenue
    FROM invoices
    GROUP BY month
)

SELECT 
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / LAG(revenue) OVER (ORDER BY month) * 100, 
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY month;

WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        SUM(i.total) AS revenue
    FROM customers c
    JOIN invoices i
    ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
ranked_customers AS (
    SELECT *,
           SUM(revenue) OVER () AS total_revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue
    FROM customer_revenue
)

SELECT 
    customer_id,
    revenue,
    ROUND((revenue / total_revenue) * 100, 2) AS revenue_percentage,
    ROUND((cumulative_revenue / total_revenue) * 100, 2) AS cumulative_percentage
FROM ranked_customers
ORDER BY revenue DESC;

SELECT 
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(total) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM invoices;


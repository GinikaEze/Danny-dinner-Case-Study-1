
Select * from menu
Select
	S.customer_id,Sum( M.price) As Total_Amount_Spent
from 
	sales As S INNER JOIN menu As M 
	ON S.product_id=M.product_id

GROUP BY customer_id
ORDER BY Total_Amount_Spent DESC


Select
	customer_id As customer,
	Count(Distinct (order_date)) As Number_of_Visit
From
	sales
GROUP BY customer_id
ORDER By Number_of_Visit Desc


-- 3. What was the first item from the menu purchased by each customer?
WITH CTE_CustomerPurchase AS (
    SELECT 
        customer_id,
        order_date,
        product_name,
        RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS DateRank 
    FROM 
        sales AS S 
        INNER JOIN menu AS M ON S.product_id = M.product_id
)
SELECT 
    customer_id,
    product_name
FROM 
    CTE_CustomerPurchase
WHERE 
    DateRank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
    product_name,
    COUNT(s.product_id) AS TotalPurchase
FROM 
    sales AS S 
    INNER JOIN menu AS M ON S.product_id = M.product_id
GROUP BY 
    product_name
ORDER BY 
    TotalPurchase DESC;

-- 5. Which item was the most popular for each customer?
WITH CTE_CustomerPurchase AS (
    SELECT 
        customer_id,
        product_name,
        COUNT(product_name) AS TotalPurchase,
        RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS ProductRank
    FROM 
        sales AS S 
        INNER JOIN menu AS M ON S.product_id = M.product_id
    GROUP BY 
        product_name,
        customer_id
)

SELECT 
    customer_id,
    product_name
FROM 
    CTE_CustomerPurchase
WHERE 
    ProductRank = 1;

    ----6.	Which item was purchased first by the customer after they became a member?-----

With CTE_MemberPUrchase AS (

Select
	S.customer_id,
	product_name,
	join_date,
	order_date,
	Rank() Over (Partition By S.customer_id Order By order_date) AS PurchaseRank
From sales As S
	INNER JOIN menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id

Where
	order_date >=join_date

)

Select
	customer_id,
	product_name
From
	CTE_MemberPurchase
Where
	PurchaseRank =1

	---7. Which item was purchased just before the customer became a member?---


With CTE_MemberPUrchase AS (

Select
	S.customer_id,
	product_name,
	join_date,
	order_date,
	Rank() Over (Partition By S.customer_id Order By order_date) AS PurchaseRank
From sales As S
	INNER JOIN menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id

Where
	order_date < join_date

)

Select
	customer_id,
	product_name
From
	CTE_MemberPurchase
Where
	PurchaseRank =1


---8. What is the total items and amount spent for each member before they became a member?---

Select
	S.customer_id,
	COUNT(S.product_id) AS TotalProduct,
	SUM(M.price) AS TotalAccount
From sales As S
	INNER JOIN menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id

Where
	order_date < join_date

Group By 
	S.customer_id

---9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?---

SELECT
	customer_id,
	SUM(
			CASE product_name	
				WHEN 'sushi' THEN price * 10 * 2  
				ELSE price * 10 
				END) AS TotalPoints
FROM 
	sales AS S 
	INNER JOIN	menu AS M
	ON S.product_id = M.product_id
GROUP BY 
	customer_id
ORDER BY TotalPoints DESC

---10. In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?---


SELECT
	S.customer_id,
	SUM(
			CASE When S.order_date Between Mem.join_date AND DateAdd(day,6,Mem.join_date) THEN price * 10 * 2
			WHEN product_name =	 'sushi' THEN price * 10 * 2  
				ELSE price * 10 
				END) AS TotalPoints
FROM 
	sales AS S 
	INNER JOIN	menu AS M
	ON S.product_id = M.product_id
	INNER JOIN members AS Mem
	ON S.customer_id= Mem.customer_id
Where YEAR(S.order_date)= 2021 AND MONTH(S.order_date) =1
GROUP BY 
	S.customer_id
ORDER BY TotalPoints DESC
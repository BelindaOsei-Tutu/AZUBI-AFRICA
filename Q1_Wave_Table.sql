--Q1
--Use the Count function on user id (u_id) to determine the number of users in Wave from the 'u_id' column.
SELECT count(u_id) FROM users;



--Q2
--Rows with receive_amount_currency in the transfers table
--Use the Count function on the transfer_id to find the number of public transactions executed.
--Use the WHERE clause to find the send amount and received amount in CFA respectively
SELECT COUNT(transfer_id) FROM public.transfers
	WHERE send_amount_currency = 'CFA';
SELECT COUNT(transfer_id) FROM public.transfers
	WHERE send_amount_currency ='CFA' AND receive_amount_currency ='CFA';
	
	
	
--Q3
--Use the Count and Distinct function on the users (u_id) from the public transfers to find the different number of users for CFA tranfer.
SELECT DISTINCT COUNT(u_id) FROM public.transfers
	WHERE send_amount_currency = 'CFA';
	
	
	
--Q4 
--Pull out all the transactions from agent transactions done in 2018. The otrder will be by month.
SELECT TO_CHAR(TO_DATE (EXTRACT(MONTH FROM when_created)::text, 'MM'), 'Month') AS months,
	COUNT(atx_id) FROM public.agent_transactions 
	WHERE EXTRACT(YEAR FROM agent_transactions.when_created) = '2018'
GROUP BY EXTRACT(MONTH FROM agent_transactions.when_created);


--Q5
--Extracting the number of withdrawals verses the number of deposits  with agent withdrawers
WITH agent_withdrawers AS
(SELECT COUNT (agent_id)
AS net_withdrawers
FROM agent_transactions 
HAVING COUNT (amount)
IN (SELECT COUNT (amount) FROM agent_transactions WHERE amount > -1 
AND amount !=0 HAVING COUNT (amount) > (SELECT COUNT(amount)
FROM agent_transactions WHERE amount < 1 AND  AMOUNT !=0)))
SELECT net_withdrawers
FROM agent_withdrawers;


--Q6
--Create a temp table which shows transactions in the past week by order of city. 
CREATE OR REPLACE VIEW atx_volume_city_summary AS
SELECT COUNT(atx_id) AS volume, city
FROM public.agent_transactions
INNER JOIN public.agents ON agents.agent_id = agent_transactions.agent_id
WHERE agent_transactions.when_created > now() -INTERVAL '7 days'
GROUP BY city;


--Q7
--From Q6 above, create a table that determines the city where the transactions took place, 
--Separate by order of country, volume
CREATE OR REPLACE VIEW atx_volume_city_summary AS
SELECT COUNT(atx_id) AS volume, city, country
FROM public.agent_transactions
INNER JOIN public.agents ON agents.agent_id = agent_transactions.agent_id
WHERE agent_transactions.when_created > now() -INTERVAL '7 days'
GROUP BY city, country;


--Q8
--order by transfer type in the past week, that is, Between '2018-11-23' AND '2018-12-30' by country, tranfer kind and volume
CREATE TABLE send_volume_by_country_and_kind AS
SELECT SUM(transfers.send_amount_scalar), wallets.ledger_location, array_agg(transfers.kind) 
FROM transfers
LEFT OUTER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
WHERE transfers.when_created > CURRENT_DATE - INTERVAL '7 days'
GROUP BY wallets.ledger_location;


--Q9
-- Adding a column to the table to display  transaction count and number of unique senders, distinct on user id
SELECT count(transfers.source_wallet_id) 
AS Unique_Senders, count(transfer_id) AS Transaction_count, transfers.kind 
AS Transfer_Kind, wallets.ledger_location AS Country, sum(transfers.send_amount_scalar) 
AS Volume FROM transfers INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id 
where (transfers.when_created > (NOW() - INTERVAL '1 week')) 
GROUP BY wallets.ledger_location, transfers.kind;   


--Q10
--Display which wallet_id has transfer amounts > 10000000
SELECT transfers.source_wallet_id, sum( transfers.send_amount_scalar) AS total_sent FROM transfers
WHERE send_amount_currency = 'CFA'
    AND (transfers.when_created > (now() - INTERVAL '10 month'))
    GROUP BY transfers.source_wallet_id
    HAVING sum( transfers.send_amount_scalar)>10000000;

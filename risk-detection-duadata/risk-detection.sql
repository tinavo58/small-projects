SELECT COUNT(*) FROM riskdetect;


SELECT * FROM riskdetect LIMIT 10;
SELECT * FROM rawRiskDetect LIMIT 10;


ALTER TABLE riskdetect
ADD COLUMN TransactionDate DATE;


SET SQL_SAFE_UPDATES = 0;
UPDATE riskdetect
SET TransactionDate = STR_TO_DATE(timestamp, "%d/%m/%Y %H:%i");
SET SQL_SAFE_UPDATES = 1;


CREATE TABLE rawRiskDetect (
customerID INT NOT NULL,
cardNumber INT NOT NULL,
amount INT NOT NULL,
transactionTakenTimestamp TEXT NOT NULL);


ALTER TABLE rawRiskDetect
MODIFY cardNumber BIGINT NOT NULL;


INSERT INTO rawRiskDetect
SELECT customerId, cardNumber, amount, timestamp FROM riskdetect;


ALTER TABLE riskdetect
DROP column timestamp;


CREATE VIEW TrasactionGreaterThan10Mil
AS
SELECT *
FROM riskdetect
WHERE amount > 10000000;


SELECT * FROM TrasactionGreaterThan10Mil;


SELECT customerId, cardNumber, TransactionDate, COUNT(*) as count_of_transactions
FROM TrasactionGreaterThan10Mil
GROUP BY customerId, cardNumber, TransactionDate
HAVING count_of_transactions > 4;
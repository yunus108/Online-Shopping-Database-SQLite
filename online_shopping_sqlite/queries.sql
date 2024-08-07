-- Find all products a seller is selling given their e-mail
SELECT * 
FROM "products" 
WHERE "seller_id" = (
    SELECT "id" FROM "seller_accounts" WHERE "e-mail" = 'johndoe123@gmail.com'
);

-- Find location info of a transaction given its id
SELECT "seller_accounts"."country" AS "From Country", "buyer_accounts"."country" AS "To Country" 
FROM "seller_accounts" 
JOIN "transactions" ON "seller_accounts"."id" = "transactions"."seller_id"
JOIN "buyer_accounts" ON "transactions"."buyer_id" = "buyer_accounts"."id" 
WHERE "transactions"."id" = 1;

-- Find all products given their categories and subcategories
SELECT * 
FROM "products" 
WHERE "category" = 'technology' AND "subcategory" = 'cell phones';

-- Find all products a buyer bought given their e-mail
SELECT * 
FROM "products" 
JOIN "transactions" ON "products"."id" = "transactions"."product_id" 
JOIN "buyer_accounts" ON "transactions"."buyer_id" = "buyer_accounts"."id" 
WHERE "buyer_id" = (
    SELECT "id" FROM "buyer_accounts" WHERE "e-mail" = 'janedoe456@gmail.com'
);

-- Add a new product
INSERT INTO "products"("seller_id", "name", "category", "subcategory", "description", "price_$")
VALUES (1, 'Phonee5', 'technology', 'cell phones', 'Latest phone of the famous company', 999.00);

-- Soft delete a seller account given its id
UPDATE "seller_accounts" SET "deleted" = 1 WHERE "id" = 26;




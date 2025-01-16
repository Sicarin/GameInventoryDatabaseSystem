 -- This file includes SQL-based solutions to meet the business requirements for the GameInventoryDB database
 USE GameInventoryDB;
 
/*
    Business Requirements #1
	----------------------------------------------------
	Purpose: Duplicate Game Prevention and Automatic Additions to User's Game Collection
	 
	Description: The system must implement a way to analyze a game being purchased through a trigger, and make sure that the game
			is not already owned by the user purchasing it. Additionally, it must be able automatically add the game to the user's 
			GameCollection for them to view, even after it is added as a GameOwnership table entry from the purchase.
	 
	Challenge: The challenge comes from consistently making sure that users purchasing games and owning them also have the games
			automatically added to their game collections, as long as it is not a duplicate.
	 
	Assumption(s): It's assumed in this scenario that one user having duplicate games is not allowed in this system. Also, 
			the PurchaseGame1 function is not meant to be comprehensive, serving just to showcase the trigger for inserting
			a new game entry in GameOwnership.
	 
	Implementation Plan:
		1. Create a trigger to prevent duplicate game purchases and add newly owned games to the user's game collection subgroup.
		2. Create a procedure to purchase a game for a user, adding it to that user's GameOwnership table.
		3. Provide example usage.
*/

DELIMITER $$
-- 1
DROP TRIGGER IF EXISTS GameOwnershipToGameCollection$$
CREATE TRIGGER GameOwnershipToGameCollection
BEFORE INSERT ON GameOwnership
FOR EACH ROW
BEGIN
	DECLARE subgroup_id INT;
    
    IF EXISTS 
    (
        SELECT 1
        FROM GameOwnership
        WHERE game_id = NEW.game_id AND registered_user_id = NEW.registered_user_id
    ) THEN
        SIGNAL SQLSTATE '45000';
    END IF;

    SELECT game_subgroup_id
    INTO subgroup_id
    FROM GameCollectionSubgroup
    WHERE registered_user_id = NEW.registered_user_id
    LIMIT 1;

    IF subgroup_id IS NOT NULL THEN
		INSERT INTO GameCollection (num_games, game_subgroup_id, game_id)
        VALUES (1, subgroup_id, NEW.game_id);
    END IF;
END$$

-- 2

DROP PROCEDURE IF EXISTS PurchaseGame1$$
CREATE PROCEDURE PurchaseGame1(IN reguser_id INT, IN new_game_id INT)
BEGIN
    INSERT INTO GameOwnership (game_id, registered_user_id, total_games_owned)
    VALUES (new_game_id, reguser_id, 1);
END$$

DELIMITER ;

-- 3

CALL PurchaseGame1(1, 2);
SELECT * FROM GameCollection;
DROP TRIGGER IF EXISTS GameOwnershipToGameCollection; 
-- This trigger interferes with the other business requirement scenarios because it prevents duplicate games owned by 1 user.

/*
    Business Requirements #2
	----------------------------------------------------
	Purpose: Game Recommendation Based on Favorite Genre
     
	Description: The system needs to allow users to change their favorite genre of game. Additionally, 
				it needs to be able to recommend a game for the user to seek out based off of their new favorite game genre.
     
	Challenge: The challenge is applying a new favorite genre to the user and searching for a game based off of it.
     
	Assumption(s): In this scenario, the system doesn't verify whether the user already owns the recommended game to 
				return a suggestion more quickly.
     
	Implementation Plan:
        1. Create a procedure to update a registered user's favorite genre, and recommend a game of that new genre.
        2. Provide example usage.
*/
  
DELIMITER $$
-- 1
DROP PROCEDURE IF EXISTS UpdateFavoriteGenre$$
CREATE PROCEDURE UpdateFavoriteGenre(IN reguser_id INT, IN new_genre_id INT)
BEGIN
    DECLARE recommended_game_title VARCHAR(45);

    UPDATE RegisteredUser
    SET favorite_genre = new_genre_id
    WHERE registered_user_id = reguser_id;

    SELECT RecGame.game_title
    INTO recommended_game_title
    FROM GameGenre FavGameGenre
    JOIN Game RecGame ON FavGameGenre.game_id = RecGame.game_id
    WHERE FavGameGenre.genre_id = new_genre_id
    LIMIT 1;

    IF recommended_game_title IS NOT NULL THEN
        SELECT CONCAT('RegUser ', reguser_id, ' favorite genre updated to ', new_genre_id, '. Recommended game is ', 
        recommended_game_title) AS message;
    ELSE
        SELECT CONCAT('RegUser ', reguser_id, ' favorite genre updated to ', new_genre_id, '. No recommendation found') AS message;
    END IF;
END $$

DELIMITER ;

-- 2

CALL UpdateFavoriteGenre(1, 2);
  
 /*
     Business Requirements #3
     ----------------------------------------------------
     Purpose: Discounted Purchase Points System to Reward Product Purchases
     
     Description: The system must implement a points system that allows users to purchase games at a discounted price by picking
				how much of a discount they want using their aquired points. It must first calculate how many points the purchase will cost,
                and check if the user can afford to use these points, storing the purchase in the user's GameOwnership table if successful.
     
     Challenge: The challenge is that the system is not aware if the user is allowed to purchase something with points, 
			so the points needed must be calculated from the game's current price and compared against the user's actual points owned.
     
     Assumption(s): It's assumed that there is already a way in place for the user to recieve points from purchasing games normally,
			so this scenario only showcases the purchase of games using these points from a user that already has them.
     
     Implementation Plan:
        1. Create a function to convert a game's price to the amount of points needed to afford part of it that the user wants.
        2. Create a procedure to insert the newly purchased game into the database after determining if the user can afford it with points.
        3. Provide example usage.
*/

DELIMITER $$
-- 1
DROP FUNCTION IF EXISTS CalculatePointsRequired$$
CREATE FUNCTION CalculatePointsRequired(game_price DECIMAL(6, 2), points_percentage DECIMAL(3, 2))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN ROUND(game_price*points_percentage*10);
    -- 1 "dollar" is equal to 10 Purchase Points
END$$

-- 2

DROP PROCEDURE IF EXISTS PurchaseWithPoints$$
CREATE PROCEDURE PurchaseWithPoints(IN new_game_id INT, IN reguser_id INT, IN points_percentage DECIMAL(3, 2))
BEGIN
    DECLARE new_game_price DECIMAL(6, 2);
    DECLARE purchase_points_needed INT;
    DECLARE user_points INT;

    SELECT TempGameMarket.game_price
    INTO new_game_price
    FROM GameMarket TempGameMarket
    WHERE TempGameMarket.game_id = new_game_id
    LIMIT 1;

    SET purchase_points_needed = CalculatePointsRequired(new_game_price, points_percentage);

    SELECT CurrRegUser.purchase_points
    INTO user_points
    FROM RegisteredUser CurrRegUser
    WHERE CurrRegUser.registered_user_id = reguser_id;

    IF user_points >= purchase_points_needed THEN
        UPDATE RegisteredUser
        SET purchase_points = purchase_points - purchase_points_needed
        WHERE registered_user_id = reguser_id;

        INSERT INTO GameOwnership (game_id, registered_user_id, total_games_owned)
        VALUES (new_game_id, reguser_id, 1);
        SELECT CONCAT('Transaction was a sucess. You used ', purchase_points_needed, ' points to buy the game') AS message;
    ELSE
        SELECT 'Not enough Purchase Points to complete the transaction' AS message;
    END IF;
END$$

DELIMITER ;

-- 3

CALL PurchaseWithPoints(2, 1, 0.50);
SELECT * FROM GameOwnership;
  
/*
    Business Requirements #4
	----------------------------------------------------
	Purpose: Game Exchange System Utilizing Purchase Points
     
	Description: The system must implement a game exchange system based on the values of the two games and
			give the user Purchase Points if needed. It should compare the prices of the two games, and simply exchange them in
            the GameOwnership table corresponding to the user if the two games have the same price. Additionally, the exchange
            shall be denied if the new game is valued more than the owned game, but if the new game is valued less than the owned
            one, the user shall recieve the appropriate Purchase Points to make up for this difference and encourage them to use
            Purchase Points.
     
	Challenge: The challenge is comparing whether the two games have the same value, or if one is worth more, 
			and properly completing the transaction for the type of success or displaying a message for a failure.
     
	Assumption(s): It's assumed that the logic for the application utilizing this database has already allowed the user
			to pick two valid games to exchange, with one being a game that they own.
     
	Implementation Plan:
        1. Create a procedure to compare two games and exchange them in the database if possible.
        2. Provide example usage.
  
*/
 
DELIMITER $$
-- 1
DROP PROCEDURE IF EXISTS ExchangeGames$$
CREATE PROCEDURE ExchangeGames(IN current_reguser_id INT, IN mygame_id INT, IN newgame_id INT)
BEGIN
    DECLARE mygame_price DECIMAL(6,2);
    DECLARE newgame_price DECIMAL(6,2);
    DECLARE price_difference DECIMAL(6,2);
    DECLARE purchase_points_earned INT;

    SELECT game_price INTO mygame_price
    FROM GameMarket
    WHERE game_id = mygame_id
    LIMIT 1;

    SELECT game_price INTO newgame_price
    FROM GameMarket
    WHERE game_id = newgame_id
    LIMIT 1;

    IF newgame_price > mygame_price THEN
        SELECT 'Your game is not equal in value to the new product' AS message;
    ELSEIF newgame_price = mygame_price THEN
        DELETE FROM GameOwnership
        WHERE game_id = mygame_id AND registered_user_id = current_reguser_id;

        INSERT INTO GameOwnership (game_id, registered_user_id, total_games_owned)
        VALUES (newgame_id, current_reguser_id, 1);
        SELECT 'Exchange was successful' AS message;
    ELSE
        SET price_difference = mygame_price - newgame_price;
        SET purchase_points_earned = ROUND(price_difference*10);

        UPDATE RegisteredUser
        SET purchase_points = purchase_points + purchase_points_earned
        WHERE registered_user_id = current_reguser_id;

        DELETE FROM GameOwnership
        WHERE game_id = mygame_id AND registered_user_id = current_reguser_id;

        INSERT INTO GameOwnership (game_id, registered_user_id, total_games_owned)
        VALUES (newgame_id, current_reguser_id, 1);
        SELECT CONCAT('Exchange was successful and ', purchase_points_earned, ' Purchase Points have been acquired') AS message;
    END IF;
END$$
  
DELIMITER ;

-- 2

CALL ExchangeGames(1, 1, 3); 
SELECT * FROM GameOwnership;
  
 /*
     Business Requirements #5
     ----------------------------------------------------
     Purpose: Automatic Price Comparisons to Find Best Deal When Purchasing Games
     
     Description: The system must be able to compare all marketplaces in the database where a game is being sold, 
				figuring out which marketplace offers the lowest price, calculate how much money was saved 
                compared to the current marketplace that the user is browsing, and complete the purchase, storing 
                the game as part of the user's collection.
     
     Challenge:  The challenge is, if the system utilizes separate stores for purchasing games, a user's purchase of a game
				in one store(marketplace) needs to be compared against every other store in the system to give them the best deal.
     
     Assumption(s): For this problem, the system already is assumed to know the current marketplace that the user is purchasing from,
				since that is where the purchase process starts. Additionally, the process of charging the user's credit card is
				excluded from this scenario, only featuring the price comparison and adding to their game collection.
     
     Implementation Plan:
        1. Create a function to compare a game's prices between two marketplaces.
        2. Create a stored procedure to insert a game purchase into the database after comparing prices.
        3. Provide example usage.
  
*/
  
DELIMITER $$
-- 1
DROP FUNCTION IF EXISTS CalculateSavings$$
CREATE FUNCTION CalculateSavings(curr_market_id INT, curr_market_price DECIMAL(6,2), low_market_id INT, low_market_price DECIMAL(6,2))
RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    IF curr_market_id = low_market_id OR curr_market_price = low_market_price THEN
        RETURN 0.00;
    ELSE
        RETURN curr_market_price - low_market_price;
    END IF;
END $$

-- 2

DROP PROCEDURE IF EXISTS PurchaseGame$$
CREATE PROCEDURE PurchaseGame(IN curr_game_id INT, IN curr_subgroup_id INT, IN curr_marketplace_id INT)
BEGIN
    DECLARE curr_market_price DECIMAL(6,2);
    DECLARE market_name VARCHAR(45);
    DECLARE low_market_price DECIMAL(6,2);
    DECLARE low_market_id INT;
    DECLARE low_market_name VARCHAR(45);
    DECLARE savings DECIMAL(6,2);
    DECLARE message TEXT;

    SELECT TempGameMarket.game_price, TempMarket.marketplace_name
    INTO curr_market_price, market_name
    FROM GameMarket TempGameMarket
    JOIN Marketplace TempMarket ON TempGameMarket.marketplace_id = TempMarket.marketplace_id
    WHERE TempGameMarket.game_id = curr_game_id AND TempGameMarket.marketplace_id = curr_marketplace_id;

    SELECT TempGameMarket.marketplace_id, TempGameMarket.game_price, TempMarket.marketplace_name
    INTO low_market_id, low_market_price, low_market_name
    FROM GameMarket TempGameMarket
    JOIN Marketplace TempMarket ON TempGameMarket.marketplace_id = TempMarket.marketplace_id
    WHERE TempGameMarket.game_id = curr_game_id
    ORDER BY TempGameMarket.game_price ASC
    LIMIT 1;

    SET savings = CalculateSavings(curr_marketplace_id, curr_market_price, low_market_id, low_market_price);

    IF savings = 0.00 THEN
        SET message = CONCAT('This is the best deal for this product at ', market_name);
    ELSE
        SET message = CONCAT('The best deal was found at ', low_market_name, ', saving you $', savings);
    END IF;

    SELECT message AS DealMessage;

    INSERT INTO GameCollection (num_games, game_subgroup_id, game_id)
    VALUES (1, curr_subgroup_id, curr_game_id);
END $$

DELIMITER ;

-- 3

CALL PurchaseGame(1, 1, 1);
-- This file inserts sample data to populate GameInventoryDB database
USE GameInventoryDB;

-- Truncating all tables to make sure they are empty first
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `User`;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Platform;
TRUNCATE TABLE GameGuild;
TRUNCATE TABLE Developer;

TRUNCATE TABLE Publisher;
TRUNCATE TABLE Game;
TRUNCATE TABLE GameParty;
TRUNCATE TABLE RegisteredUser;
TRUNCATE TABLE BestFriend;

TRUNCATE TABLE `Account`;
TRUNCATE TABLE PaymentMethod;
TRUNCATE TABLE CreditCardPaymentMethod;
TRUNCATE TABLE GameOwnership;
TRUNCATE TABLE GameGenre;

TRUNCATE TABLE Forum;
TRUNCATE TABLE DiscussionPost;
TRUNCATE TABLE DiscussionReply;
TRUNCATE TABLE ReplyParent;
TRUNCATE TABLE DeveloperGenre;

TRUNCATE TABLE DeveloperPlatform;
TRUNCATE TABLE PublisherGenre;
TRUNCATE TABLE PublisherPlatform;
TRUNCATE TABLE Marketplace;
TRUNCATE TABLE Bundle;

TRUNCATE TABLE UserBundle;
TRUNCATE TABLE GameBundle;
TRUNCATE TABLE GameCollectionSubgroup;
TRUNCATE TABLE GameCollection;
TRUNCATE TABLE GameMarket;

TRUNCATE TABLE NewsSection;
TRUNCATE TABLE NewsArticle;
TRUNCATE TABLE ArticleReading;
TRUNCATE TABLE SectionAccess;
SET FOREIGN_KEY_CHECKS = 1;

-- User Inserts
INSERT INTO `User` (user_id, tracking_id, first_time_user, has_access) VALUES
(1, 1001, TRUE, FALSE),
(2, 1002, FALSE, TRUE),
(3, 1003, TRUE, FALSE),
(4, 1004, FALSE, TRUE);

-- Genre Inserts
INSERT INTO Genre (genre_id, genre_name, custom_genre) VALUES
(1, 'Action', FALSE),
(2, 'Adventure', FALSE),
(3, 'Kaiju', TRUE);

-- Platform Inserts
INSERT INTO Platform (platform_id, platform_name, release_date) VALUES
(1, 'PlayStation 5', '2020-11-12'),
(2, 'Xbox Series S', '2020-11-10'),
(3, 'Nintendo Switch', '2017-03-03'),
(4, 'Windows PC', '1985-11-20');

-- GameGuild Inserts
INSERT INTO GameGuild (game_guild_id, platform_id, guild_name, guild_color) VALUES
(1, 2, 'GreenGhouls', 'green'),
(2, 1, 'Bluebots', 'blue'),
(3, 3, 'MushroomKingdom', 'red'),
(4, 4, 'Wakanda4Ever', 'purple');

-- Developer Inserts
INSERT INTO Developer (developer_id, developer_name, established) VALUES
(1, 'Hopoo Games', '2012-11-08'),
(2, 'Game Freak', '1989-04-26'),
(3, 'Rockstar North', '1988-12-30');

-- Publisher Inserts
INSERT INTO Publisher (publisher_id, publisher_name, established) VALUES
(1, 'Humble Bundle', '2010-11-24'),
(2, 'The Pokémon Company', '1998-04-23'),
(3, 'Rockstar Games', '1998-12-30'),
(4, 'Gearbox Publishing', '1999-02-16');

-- Game Inserts
INSERT INTO Game (game_id, game_title, developer_id, publisher_id) VALUES
(1, 'Risk of Rain 2', 1, 4),
(2, 'Pokémon Y', 2, 2),
(3, 'Grand Theft Auto V', 3, 3);

-- GameParty Inserts
INSERT INTO GameParty (game_party_id, created, game_guild_id, platform_id, game_id) VALUES
(1, '2021-04-21', 1, 2, 1),
(2, '2024-03-27', 4, 4, 3),
(3, '2024-07-05', 2, 1, 3);

-- RegisteredUser Inserts
INSERT INTO RegisteredUser (registered_user_id, user_id, favorite_genre, has_best_friend, game_party_id, game_guild_id, purchase_points) VALUES
(1, 1, 1, FALSE, 1, 1, 600),
(2, 2, 3, TRUE, 2, 4, 0),
(3, 3, 2, TRUE, 3, 2, 0),
(4, 4, 1, TRUE, 2, 4, 0);

-- BestFriend Inserts
INSERT INTO BestFriend (best_friend_id, registered_user_id) VALUES
(1, 2),
(2, 3),
(3, 4);

-- Account Inserts
INSERT INTO `Account` (account_id, registered_user_id, creation_date, is_validated) VALUES
(1, 1, '2021-04-14', TRUE),
(2, 2, '2024-03-07', TRUE),
(3, 3, '2024-07-04', TRUE);

-- PaymentMethod Inserts
INSERT INTO PaymentMethod (payment_method_id, registered_user_id, address, city, state, country, zipcode) VALUES
(1, 1, '4536 Mayo Street', 'Florence', 'KY', 'United States', '41042'),
(2, 2, '584 Richards Avenue', 'Stockton', 'CA', 'United States', '95202'),
(3, 3, '1779 Stutler Lane', 'Erie', 'PA', 'United States', '16510');

-- CreditCardPaymentMethod Inserts
INSERT INTO CreditCardPaymentMethod (card_id, payment_method_id, bank_code, verification_value, expiration_date, card_number) VALUES
(1, 1, '124085066', '330', '2025-02-01', '377522914801152'),
(2, 2, '124085066', '879', '2025-03-01', '377522269135743'),
(3, 3, '124085066', '418', '2025-06-01', '377511425413961');

-- GameOwnership Inserts
INSERT INTO GameOwnership (game_ownership_id, game_id, registered_user_id, total_games_owned) VALUES
(1, 1, 1, 1),
(2, 3, 2, 1),
(3, 3, 3, 1);

-- GameGenre Inserts
INSERT INTO GameGenre (game_genre_id, subgenre, game_id, genre_id) VALUES
(1, 'Roguelike', 1, 1),
(2, 'Role-playing', 2, 2),
(3, 'Open World', 3, 1);

-- Forum Inserts
INSERT INTO Forum (forum_id, forum_name, topic) VALUES
(1, 'Help and Tips', 'help'),
(2, 'Off Topic', 'miscellaneous'),
(3, 'Pokémon X and Pokémon Y', 'game');

-- DiscussionPost Inserts
INSERT INTO DiscussionPost(discussion_post_id, forum_id, registered_user_id, topic, created) VALUES
(1, 1, 1, 'Adding friends', '2021-04-15'),
(2, 2, 2, 'my favorite songs', '2024-03-08'),
(3, 3, 3, 'Best Starter', '2024-07-05');

-- DiscussionReply Inserts
INSERT INTO DiscussionReply(discussion_reply_id, discussion_post_id, registered_user_id, created, has_reply_parent) VALUES
(1, 1, 2, '2024-03-09', TRUE),
(2, 2, 3, '2024-07-06', TRUE),
(3, 3, 1, '2024-07-07', TRUE);

-- ReplyParent Inserts
INSERT INTO ReplyParent(reply_parent_id, discussion_reply_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- DeveloperGenre Inserts
INSERT INTO DeveloperGenre(developer_genre_id, games_developed, developer_id, genre_id) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 1, 3, 1);

-- DeveloperPlatform Inserts
INSERT INTO DeveloperPlatform(developer_platform_id, games_developed, developer_id, platform_id) VALUES
(1, 1, 1, 2),
(2, 1, 2, 3),
(3, 1, 3, 1);

-- PublisherGenre Inserts
INSERT INTO PublisherGenre(publisher_genre_id, games_published, publisher_id, genre_id) VALUES
(1, 1, 2, 2),
(2, 1, 3, 1),
(3, 1, 4, 1);

-- PublisherPlatform Inserts
INSERT INTO PublisherPlatform(publisher_platform_id, games_published, publisher_id, platform_id) VALUES
(1, 1, 2, 3),
(2, 1, 3, 1),
(3, 1, 4, 2);

-- Marketplace Inserts
INSERT INTO Marketplace(marketplace_id, marketplace_name, num_games) VALUES
(1, 'Vapor', 3),
(2, 'Legendary Games', 0),
(3, 'Modest Games', 0);

-- Bundle Inserts
INSERT INTO Bundle(bundle_id, bundle_name, genre_id, marketplace_id) VALUES
(1, 'Action-Packed!', 1, 1),
(2, 'Into the Woods', 2, 1),
(3, 'Indie Delights', 1, 1);

-- UserBundle Inserts
INSERT INTO UserBundle(user_bundle_id, date_purchased, bundle_id, registered_user_id) VALUES
(1, '2021-05-21', 1, 1),
(2, '2021-05-22', 2, 1),
(3, '2021-05-23', 3, 1);

-- GameBundle Inserts
INSERT INTO GameBundle(game_bundle_id, num_games, game_id, bundle_id) VALUES
(1, 1, 3, 1),
(2, 1, 2, 2),
(3, 1, 1, 3);

-- GameCollectionSubgroup Inserts
INSERT INTO GameCollectionSubgroup(game_subgroup_id, genre, registered_user_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1);

-- GameCollection Inserts
INSERT INTO GameCollection(game_collection_id, num_games, game_subgroup_id, game_id) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1),
(3, 1, 3, 2);

-- GameMarket Inserts
INSERT INTO GameMarket(game_market_id, game_price, game_id, marketplace_id) VALUES
(1, 25.00, 1, 1),
(2, 40.00, 2, 1),
(3, 15.00, 3, 1),
(4, 20.00, 1, 2);

-- NewsSection Inserts
INSERT INTO NewsSection(news_section_id, num_articles, section_head) VALUES
(1, 1, 'Ray Miller'),
(2, 1, 'Stacy Swift'),
(3, 1, 'Lonnie Bryant');

-- NewsArticle Inserts
INSERT INTO NewsArticle(article_id, article_title, created, topic, author, news_section_id) VALUES
(1, 'The 11 Best Dragon Ball: Sparking Zero Mods', '2024-02-21', 'Games', 'Janie Whitaker', 1),
(2, 'Coca-Cola''s New AI Christmas Ad Looks Terrible', '2024-03-27', 'Entertainment', 'Jennie Read', 2),
(3, 'Astro Bot: Review', '2024-07-26', 'Reviews', 'Joyce Moon', 3);

-- ArticleReading Inserts
INSERT INTO ArticleReading(article_reading_id, accessed, article_id, user_id) VALUES
(1, '2024-03-21', 1, 2),
(2, '2024-04-27', 2, 2),
(3, '2024-08-26', 3, 2);

-- SectionAccess Inserts
INSERT INTO SectionAccess(section_access_id, news_section_id, user_id, accessed) VALUES
(1, 1, 2, '2024-03-21'),
(2, 2, 2, '2024-04-27'),
(3, 3, 2, '2024-08-26');




/* INTRODUCTION & EXTERNAL SOURCES
When planning a wedding, size and budget are two of the most important factors to consider carefully. 
According to industry experts, wedding sizes are typically categorized into small, medium and large. 
Small weddings include no more than 50 guests, medium weddings range from 51 to 150 guests, and large weddings have more than 150 participants.
(The list. (2023, March 4). What size of wedding is right for you? We have the calculations you need to decide. 
Retrieved from https://www.thelist.com/1213544/what-size-wedding-is-right-for-you-weve-got-the-calculations-you-need-to-decide/). 
To accurately estimate wedding costs, it is essential to understand the price structure of each department.
Each department has provided price levels in relation to its product category, facilitating the accurate assignment of 
items to their respective budget categories: "inexpensive," "affordable," "moderate," and "luxury."
*/


/* ASSUMPTIONS:
To plan for different wedding sizes, we've established that music, photography,
hair and makeup, dress and  attire, and jewelry, can deliver the service without being influenced by the number of the guests.
In contrast, catering, flowers, rentals, and invitations adjust according to the number of attendees. 
Catering is priced at $20 per guest. 
Flower choices consider proximity to the venue and suitability 
for the wedding's rustic theme and size (For example: Florally Fleurish - 29.9 miles away from the selected venue
and the Prickly Petal Flower co - 19.7 miles away from the selected venue).
 Venue selection is based on  rustic theme and the fact that can be flexible, with the ability to tailor 
 spaces for an intimate feel in smaller weddings. Each vendor's capacity 
 for different wedding sizes was evaluated during the selection process.
*/

-- import wedding_database from cohort to use on analysis
USE wedding_database;

-- Drop and create of the temporary table:
DROP TEMPORARY TABLE IF EXISTS relevant_vendors;
CREATE TEMPORARY TABLE relevant_vendors AS

SELECT 
    v.vendor_id,
    v.vendor_name,

/* We generated 2 additional columns called wedding size and budget level by using nested case statment to avoid using joins.
Each case statement relates to a specific department and their predefined range for budget level.*/
    CASE
        WHEN
            vendor_depart = 'flowers'
        THEN
        -- Flowers Department budget level range
            CASE
                WHEN p.price_ce = 1 THEN 'Inexpensive'
                WHEN p.price_ce = 2 THEN 'Affordable'
                WHEN p.price_ce = 3 THEN 'Moderate'
                WHEN p.price_ce = 4 THEN 'Luxury'
            END
        WHEN
            vendor_depart = 'venues'
        THEN
        -- Venues Department budget level range
            CASE
                WHEN p.price_unit <= 3500 THEN 'Inexpensive'
                WHEN
                    p.price_unit > 3500
                        AND price_unit <= 11667
                THEN
                    'Affordable'
                WHEN
                    p.price_unit > 11667
                        AND price_unit <= 19833
                THEN
                    'Moderate'
                WHEN p.price_unit > 19833 THEN 'Luxury'
            END
        WHEN
            vendor_depart = 'music'
        THEN
        -- Music Department budget level range
            CASE
                WHEN
                    p.price_unit > 500
                        AND price_unit <= 1100
                THEN
                    'Inexpensive'
                WHEN
                    p.price_unit > 1100
                        AND price_unit <= 1500
                THEN
                    'Affordable'
                WHEN
                    p.price_unit > 1500
                        AND price_unit <= 2650
                THEN
                    'Moderate'
                WHEN
                    p.price_unit > 2650
                        AND price_unit <= 7000
                THEN
                    'Luxury'
                WHEN p.price_unit > 1795 THEN 'Unknown Price'
            END
        WHEN
            vendor_depart = 'jewelry'
        THEN
        -- Jewelry Department budget level range
            CASE
                WHEN p.price_unit BETWEEN 0 AND 950 THEN 'Inexpensive'
                WHEN p.price_unit BETWEEN 951 AND 1895 THEN 'Affordable'
                WHEN p.price_unit BETWEEN 1896 AND 3150 THEN 'Moderate'
                WHEN p.price_unit > 3150 THEN 'Luxury'
                ELSE 'Price Unknown'
            END
        WHEN
            vendor_depart = 'hair and makeup'
        THEN
        -- Hair and Makeup Department budget level range
            CASE
                WHEN price_unit <= 150 THEN 'Inexpensive'
                WHEN price_unit > 151 AND price_unit <= 250 THEN 'Affordable'
                WHEN price_unit > 251 AND price_unit <= 350 THEN 'Moderate'
                WHEN price_unit >= 351 THEN 'Luxury'
                ELSE 'Unknown Price'
            END
        WHEN
            vendor_depart = 'photo and video'
        THEN
        -- Photo and Videos Department budget level range
            CASE
                WHEN p.price_unit <= 1527 THEN 'Inexpensive'
                WHEN
                    p.price_unit > 1528
                        AND p.price_unit <= 3054
                THEN
                    'Affordable'
                WHEN
                    p.price_unit > 3055
                        AND p.price_unit <= 4581
                THEN
                    'Moderate'
                WHEN p.price_unit >= 4582 THEN 'Luxury'
                ELSE 'Unknown Price'
            END
        WHEN
            vendor_depart = 'invitations'
        THEN
        -- Invitations Department budget level range
            CASE
                WHEN p.price_unit BETWEEN 0 AND 98.17 THEN 'Inexpensive'
                WHEN p.price_unit BETWEEN 98.18 AND 196.33 THEN 'Affordable'
                WHEN p.price_unit BETWEEN 196.34 AND 294.50 THEN 'Moderate'
                WHEN p.price_unit > 294.51 THEN 'Luxury'
                ELSE 'Price Unknown'
            END
        WHEN
            vendor_depart = 'rental'
        THEN
        -- Rental Department budget level range
            CASE
                WHEN p.price_unit BETWEEN 0 AND 0.85 THEN 'Inexpensive'
                WHEN p.price_unit BETWEEN 0.86 AND 3.00 THEN 'Affordable'
                WHEN p.price_unit BETWEEN 3.01 AND 11.50 THEN 'Moderate'
                WHEN p.price_unit > 11.51 THEN 'Luxury'
                ELSE 'Price Unknown'
            END
        WHEN
            vendor_depart = 'catering'
        THEN
        -- Catering Department budget level range
            CASE
                WHEN p.price_unit BETWEEN 8 AND 25 THEN 'Inexpensive'
                WHEN p.price_unit BETWEEN 25 AND 45 THEN 'Affordable'
                WHEN p.price_unit BETWEEN 45 AND 90 THEN 'Moderate'
                WHEN p.price_unit > 90 THEN 'Luxury'
                ELSE 'Price Unknown'
            END
        WHEN
            vendor_depart = 'dress and attire'
        THEN
        -- Dress and Attire Department bugdet level range
            CASE
                WHEN p.price_unit BETWEEN 0 AND 375 THEN 'Inexpensive'
                WHEN p.price_unit BETWEEN 376 AND 469 THEN 'Affordable'
                WHEN p.price_unit BETWEEN 470 AND 522.50 THEN 'Moderate'
                WHEN p.price_unit > 523 THEN 'Luxury'
                ELSE 'Price Unknown'
            END
    END AS budget_level,
    
/*For the 'wedding_size' variable, we conducted an analysis of venue capacities by visiting various websites. 
 The primary factor influencing these capacities was found to be the venue's location relative to San Francisco. 
 The correlation was categorized as follows:
 Small: A venue located within a 30-minute drive or less from San Francisco.
 Medium: A venue situated between a 31 to 59-minute drive from San Francisco.
 Large: A venue that requires 60 minutes or more of driving time from San Francisco.*/

    CASE
        WHEN LOWER(TRIM(v.vendor_location)) IN ('san francisco' , 'oakland') THEN 'Small'
        WHEN
            LOWER(TRIM(v.vendor_location)) IN ('half moon bay' , 'el cerrito',
                'berkeley',
                'tiburon',
                'menlo park',
                'san mateo',
                'stanford',
                'san anselmo',
                'novato',
                'richmond',
                'sausalito')
        THEN
            'Medium'
        WHEN
            LOWER(TRIM(v.vendor_location)) IN ('san ramon' , 'acampo',
                'hollister',
                'pleasanton',
                'walnut creek',
                'nicasio',
                'san jose',
                'livermore',
                'vacaville',
                'clayton',
                'mammoth lakes',
                'cloverdale',
                'felton',
                'dixon',
                'pescadero',
                'los gatos',
                'sunol',
                'calistoga',
                'oakley',
                'campbell')
        THEN
            'Large'
        ELSE 'Online'
    END AS wedding_size
FROM
    vendors v
    
    -- Join used to add the vendors table
        JOIN
    products p ON v.vendor_id = p.vendor_id

-- Filtering the relevant products to our theme retrieved from the previous steps of gathering the relevant vendors according to our Rustic theme
-- and vision board. 
WHERE
    p.product_id IN ('prod_210' ,
        'prod_124',
        'prod_125',
        'prod_126',
        'prod_118',
        'prod_360',
        'prod_331',
        'prod_346',
        'prod_354',
        'prod_388',
        'prod_383',
        'prod_379',
        'prod_367',
        'prod_635',
        'prod_636',
        'prod_759',
        'prod_634',
        'prod_840',
        'prod_841',
        'prod_842',
        'prod_843',
        'prod_844',
        'prod_845',
        'prod_846',
        'prod_847',
        'prod_848',
        'prod_849',
        'prod_850',
        'prod_851',
        'prod_852',
        'prod_853',
        'prod_854',
        'prod_805',
        'prod_807',
        'prod_808',
        'prod_809',
        'prod_811',
        'prod_815',
        'prod_819',
        'prod_822',
        'prod_824',
        'prod_836',
        'prod_838',
        'prod_239',
        'prod_261',
        'prod_282',
        'prod_302',
        'prod_320',
        'prod_067',
        'prod_073',
        'prod_061',
        'prod_068',
        'prod_072',
        'prod_064',
        'prod_081',
        'prod_066',
        'prod_071',
        'prod_083',
        'prod_063',
        'prod_074',
        'prod_039',
        'prod_214',
        'prod_188', 
        'prod_007',
        'prod_145',
        'prod_139',
        'prod_163',
        'prod_164', 
        'prod_224'
        );
        
-- Second Temporary Table for vendor_options
        
DROP TEMPORARY TABLE IF exists vendor_options;

/* CREATE TABLE */
CREATE TEMPORARY TABLE vendor_options(
id integer,
wedding_size VARCHAR(100),
budget_level VARCHAR(100),
flowers_vendor_id VARCHAR(100),
flowers_cost float,
venues_vendor_id VARCHAR(100),
venues_cost float,
music_vendor_id VARCHAR(100),
music_cost float,
jewelry_vendor_id VARCHAR(100),
jewelry_cost float,
photo_video_vendor_id VARCHAR(100),
photo_video_cost float,
hair_makeup_vendor_id VARCHAR(100),
hair_makeup_cost float,
attire_vendor_id VARCHAR(100),
attire_cost float,
catering_vendor_id VARCHAR(100),
catering_cost float,
rentals_vendor_id VARCHAR(100),
rentals_cost float,
invitations_vendor_id VARCHAR(100),
invitations_cost float,
dress_vendor_id VARCHAR(100),
dress_cost float,
wedding_theme VARCHAR(100),
est_cost float
);

-- Inserting the the queries to come up with the table from the excel sheet
/* INSERT QUERY NO: 1 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
1, 'Small', 'Inexpensive', 'flo_05', 5, 'ven_39', 5100, 'dj_22', 650, 'jwl_04', 2453, 'vid_25', 1500, 'hmu_19', 81, 'att_04', 320, 'cat_36', 1000, 'ren_02', 0.8, 'inv_06', 88.8, 'att_14', 249.99, 'Rustic', 11448.59
);

/* INSERT QUERY NO: 2 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
2, 'Small', 'Affordable', 'flo_31', 100, 'ven_39', 5100, 'dj_34', 1795, 'jwl_04', 2453, 'vid_20', 2291, 'hmu_19', 175, 'att_12', 450, 'cat_36', 1000, 'ren_16', 1.5, 'inv_30', 125.4, 'att_17', 469, 'Rustic', 13959.9
);

/* INSERT QUERY NO: 3 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
3, 'Small', 'Moderate', 'flo_31', 100, 'ven_39', 5100, 'dj_02', 2500, 'jwl_03', 1895, 'vid_16', 3818, 'hmu_32', 254, 'att_12', 450, 'cat_36', 1000, 'ren_03', 9.25, 'inv_12', 284.34, 'att_17', 495, 'Rustic', 15905.59
);

/* INSERT QUERY NO: 4 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
4, 'Small', 'Luxury', 'flo_41', 200, 'ven_39', 5100, 'dj_01', 5000, 'jwl_04', 5744, 'vid_04', 4582, 'hmu_19', 357, 'att_03', 537, 'cat_36', 1000, 'ren_24', 25, 'inv_31', 392.66, 'att_15', 550, 'Rustic', 23487.66
);

/* INSERT QUERY NO: 5 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
5, 'Medium', 'Inexpensive', 'flo_05', 5, 'ven_39', 5100, 'dj_22', 650, 'jwl_04', 2453, 'vid_25', 1500, 'hmu_19', 81, 'att_05', 189, 'cat_36', 3000, 'ren_04', 0.52, 'inv_06', 88.8, 'att_17', 206, 'Rustic', 13273.32
);

/* INSERT QUERY NO: 6 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
6, 'Medium', 'Affordable', 'flo_31', 100, 'ven_39', 5100, 'dj_34', 1795, 'jwl_04', 2453, 'vid_20', 2291, 'hmu_19', 175, 'att_06', 404, 'cat_36', 3000, 'ren_07', 2, 'inv_30', 125.4, 'att_17', 469, 'Rustic', 15914.4
);

/* INSERT QUERY NO: 7 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
7, 'Medium', 'Moderate', 'flo_31', 100, 'ven_39', 5100, 'dj_02', 2500, 'jwl_03', 1895, 'vid_16', 3818, 'hmu_32', 254, 'att_06', 404, 'cat_36', 3000, 'ren_12', 9.25, 'inv_12', 284.34, 'att_17', 495, 'Rustic', 17859.59
);

/* INSERT QUERY NO: 8 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
8, 'Medium', 'Luxury', 'flo_41', 200, 'ven_39', 5100, 'dj_01', 5000, 'jwl_04', 5744, 'vid_04', 4582, 'hmu_19', 357, 'att_01', 1750, 'cat_36', 3000, 'ren_24', 25, 'inv_31', 392.66, 'att_16', 3495, 'Rustic', 29645.66
);

/* INSERT QUERY NO: 9 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
9, 'Large', 'Inexpensive', 'flo_05', 5, 'ven_39', 5100, 'dj_22', 650, 'jwl_04', 2453, 'vid_25', 3000, 'hmu_19', 81, 'att_05', 189, 'cat_36', 4000, 'ren_17', 0.7, 'inv_06', 88.8, 'att_17', 206, 'Rustic', 15773.5
);

/* INSERT QUERY NO: 10 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
10, 'Large', 'Affordable', 'flo_31', 100, 'ven_39', 5100, 'dj_34', 1795, 'jwl_04', 2453, 'vid_20', 4582, 'hmu_19', 175, 'att_12', 450, 'cat_36', 4000, 'ren_22', 1, 'inv_30', 125.4, 'att_17', 469, 'Rustic', 19250.4
);

/* INSERT QUERY NO: 11 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
11, 'Large', 'Moderate', 'flo_31', 100, 'ven_39', 5100, 'dj_02', 2500, 'jwl_03', 1895, 'vid_16', 7636, 'hmu_32', 254, 'att_12', 450, 'cat_36', 4000, 'ren_21', 11.5, 'inv_12', 284.34, 'att_17', 495, 'Rustic', 22725.84
);

/* INSERT QUERY NO: 12 */
INSERT INTO vendor_options(id, wedding_size, budget_level, flowers_vendor_id, flowers_cost, venues_vendor_id, venues_cost, music_vendor_id, music_cost, jewelry_vendor_id, jewelry_cost, photo_video_vendor_id, photo_video_cost, hair_makeup_vendor_id, hair_makeup_cost, attire_vendor_id, attire_cost, catering_vendor_id, catering_cost, rentals_vendor_id, rentals_cost, invitations_vendor_id, invitations_cost, dress_vendor_id, dress_cost, wedding_theme, est_cost)
VALUES
(
12, 'Large', 'Luxury', 'flo_41', 200, 'ven_39', 5100, 'dj_01', 5000, 'jwl_04', 5744, 'vid_04', 9164, 'hmu_19', 357, 'att_02', 2250, 'cat_36', 4000, 'ren_24', 25, 'inv_31', 392.66, 'att_16', 3495, 'Rustic', 35727.66
);

-- Final temporary table from the previously created temporary tables
SELECT *
FROM vendor_options;
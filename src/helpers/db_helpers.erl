-module(db_helpers).
-export([
    get_all_user_names/0
    ,check_valid_user/1
    ,get_number_of_users/0
    ,log_in_user/3
    ,customer_id_given_fbuid/1
    ,update_customer_name/2 
    ,customer_details_given_firebase_uid/1
    ,update_customer_address/9
    ,update_customer_profile/10
    ,fcm_token_given_customer_id/1
    ,customer_fcm_given_order_id/1
    ]).
-export([
    orders_given_customer_id/1
    ,order_items_given_order_id/1
    ,order_details_given_order_id/1
    ,add_order_item/3
    ,update_order_item/3
    ,delete_order_item_given_id/1
    ,add_order/2
    ,add_order/3
    ,delete_order_given_id/1
    ,link_store_to_order/5
    ,payment_made/5
    ,save_order/2
    ]).
-export([
    stores_given_customer_id/1
    ,default_store_given_customer_uid/1
    ,store_id_given_fbuid/1
    ,store_refer_customer/3
    ,store_delete_customer/2
    % ,store_fcm_given_id/1
    ,store_fcms_given_id/1
    ,referred_customers_given_store/1
    ,customers_given_store/1
    ,store_name_given_order_id/1
    ]).
-export([
    % log_in_store/3
    log_in_store/2
    ,update_store_fcm/2
    ,update_store_name/2 
    ,store_details_given_firebase_uid/1
    ,update_store_address/9
    ,update_store_services/4
    ,update_store_payments/3
    ,orders_given_store_id/1
    ,store_confirm_order/1
    ,store_confirm_fulfil/1
    ,store_confirm_payment/1
    ]).
-export([
    get_states_list/0
    ,get_stores_in_state/1
    ,get_orders_in_state/1
    ,get_customers_referred_by_stores_in_state/1
    ,get_users_in_state/1
    ,orders_by_store_1/1
    ,orders_by_store_2/2
    ]).
-export([
    add_loyalty_code_customer/2
]).

get_all_user_names() -> 
    #{result := Result} = 
        db_connector:simple_query("select name from customer"),
    Result.

check_valid_user(FirebaseUid) -> 
    #{result := [#{count := Count}]} =
    db_connector:extended_query(
      "
      with a as
        (
            select c.firebase_auth_uid fbuid from customer c
            union
            select s.firebase_auth_uid from store s
        )
      select count(fbuid)
      from a
      where a.fbuid = $1
      ",
      [FirebaseUid]),
    Count.

get_number_of_users() -> 
    #{num_rows := NumRows} = 
        db_connector:simple_query("select name from customer"),
    NumRows.

log_in_user(FirebaseUid, FcmToken, MobileNumber) -> 
    #{num_rows := NumRows} = db_connector:extended_query(
        "
        insert into customer(fcm_token, mobile_number, firebase_auth_uid) 
        values($1, $2, $3)
        on conflict (firebase_auth_uid)
        do update
        set fcm_token = excluded.fcm_token 
        where (
            customer.fcm_token != excluded.fcm_token 
            OR 
            customer.fcm_token IS NULL
        )
        ", 
        [FcmToken, MobileNumber, FirebaseUid]),
    NumRows.

customer_id_given_fbuid(FireBaseUid) ->
    #{result := [#{customer_id := CustomerId}]} = 
    db_connector:extended_query(
        "
        select customer_id from customer 
        where firebase_auth_uid = $1
        order by time_of_creation desc limit 1
        ",
        [FireBaseUid]),
    CustomerId.

%% todo - redo to get list of fcm tokens per cust id
fcm_token_given_customer_id(CustomerId) ->
    #{result := [#{fcm_token := FcmToken}]} = 
    db_connector:extended_query(
        "
        select fcm_token from customer 
        where customer_id = $1
        order by time_of_creation desc limit 1
        ",
        [CustomerId]),
    FcmToken.

% orders_given_customer_id(CustomerId) -> 
    % #{num_rows := N, result := Orders} = 
    % db_connector:extended_query(
        % "
        % select * from orders 
        % where customer_id = $1
        % ",
    % [CustomerId]),
    % #{ num_rows => N, orders => Orders}.

orders_given_customer_id(CustomerId) -> 
    #{num_rows := N, result := Orders} = 
    db_connector:extended_query(
        "
        select o.*,
            s.name as store_name,
            s.mobile_number as store_number,
            s.store_id as store_id
        from orders o
        left join store s
        on o.store_id = s.store_id
        where o.customer_id=$1
        ",
    [CustomerId]),
    #{ num_rows => N, orders => Orders}.

% todo - when the server is used to get/add items, 
% OrderId might need to be a binary instead of integer. check. 
order_items_given_order_id(OrderId) ->
    #{num_rows := N, result := OrderItems} = 
    db_connector:extended_query(
        "
        select * from order_item 
        where order_id = $1
        ",
    [binary_to_integer(OrderId)]),
    #{ num_rows => N, order_items => OrderItems}.

order_details_given_order_id(OrderId) ->
    #{num_rows := N, result := [#{data := OrderDetails}]} = 
    db_connector:extended_query(
        "
        select data from order_detail 
        where order_id = $1
        ",
    [binary_to_integer(OrderId)]),
    #{ num_rows => N, order_details => OrderDetails}.

% todo - when the server is used to get/add items, 
% OrderItemId might need to be a binary instead of integer. check. 
delete_order_item_given_id(OrderItemId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        delete from order_item 
        where order_item_id = $1
        ",
    [binary_to_integer(OrderItemId)]),
    #{ num_rows => N}.

add_order_item(OrderName, OrderQuantity, OrderId) -> 
    #{num_rows := NumRows, result := [#{order_item_id := OrderItemId}]} =
    db_connector:extended_query(
        "
        insert into order_item(name, quantity, order_id) 
        values($1, $2, $3)
        returning order_item_id
        ", 
        [OrderName, OrderQuantity, OrderId]),
    #{num_rows => NumRows, order_item_id => OrderItemId}.

update_customer_name(CustomerName, FireBaseUid) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update customer set name = $1
        where firebase_auth_uid = $2
        ",
    [CustomerName, FireBaseUid]),
    #{ num_rows => N}.

update_customer_address(
    FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update customer set 
            address_line1 = $2,
            address_line2 = $3,
            city = $4,
            state = $5,
            pincode = $6,
            latitude = $7,
            longitude = $8,
            geo_accuracy = $9
        where firebase_auth_uid = $1
        ",
    [FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy]),
    #{ num_rows => N}.

update_customer_profile(
    FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy, CustomerName ) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update customer set 
            address_line1 = $2,
            address_line2 = $3,
            city = $4,
            state = $5,
            pincode = $6,
            latitude = $7,
            longitude = $8,
            geo_accuracy = $9,
            name = $10
        where firebase_auth_uid = $1
        ",
    [FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy, CustomerName ]),
    #{ num_rows => N}.


customer_details_given_firebase_uid(FireBaseUid) ->
    #{ num_rows := N, result := [#{
        name := UserName, address_line1 := AddressLine1, 
        address_line2 := AddressLine2, city := City, 
        state := State, pincode := Pincode,
        latitude := Latitude, longitude := Longitude,
        loyalty_code := LoyaltyCode
    }]} = db_connector:extended_query(
        "
        select name, address_line1, address_line2, city, state, pincode, latitude, longitude, loyalty_code
        from customer 
        where firebase_auth_uid = $1
        ",
        [FireBaseUid]),
    #{
        num_rows => N, username => UserName, 
        address_line1 => AddressLine1, address_line2 => AddressLine2, 
        city => City, state => State, pincode => Pincode,
        latitude => Latitude, longitude => Longitude,
        loyalty_code => LoyaltyCode
    }.

add_order(CustomerId, Category) ->
    #{num_rows := NumRows, result := [Order]} =
    db_connector:extended_query(
        "
        insert into orders(customer_id, category)
        values($1, $2)
        returning *
        ", 
        [CustomerId, Category]),
    #{num_rows => NumRows, order => Order}.

add_order(CustomerId, Category, StoreId) ->
    #{num_rows := NumRows, result := [Order]} =
    db_connector:extended_query(
        "
        insert into orders(customer_id, category, store_id)
        values($1, $2, $3)
        returning *
        ", 
        [CustomerId, Category, StoreId]),
    #{num_rows => NumRows, order => Order}.

delete_order_given_id(OrderId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        delete from orders
        where order_id = $1
        ",
    [binary_to_integer(OrderId)]),
    % [(OrderId)]),
    #{ num_rows => N}.

default_store_given_customer_uid(CustomerUid) ->
    #{num_rows := NumRows, result := DefaultStore} = 
    db_connector:extended_query(
        "
        select s.* from 
            customer c join customer_referred_by_store crs 
            on c.mobile_number = crs.customer_mobile_number join store s 
            on crs.store_id = s.store_id 
        where c.firebase_auth_uid = $1;
        ",
        [CustomerUid]),
    #{num_rows => NumRows, default_store => DefaultStore}.

stores_given_customer_id(CustomerId) ->
    #{num_rows := NumRows, result := Stores} = 
    db_connector:extended_query(
        "
        -- select s.name as store_name, s.store_id as store_id,
        -- s.offers_delivery as offers_delivery, s.offers_pickup as offers_pickup, 
        -- s.payment_cash, s.payment_online, s.payment_credit
        select s.*
        from store s,
        lateral (
            select latitude, longitude 
            from customer where customer_id = $1
        ) as c 
        where earth_distance(
            ll_to_earth(s.latitude, s.longitude),
            ll_to_earth(c.latitude, c.longitude)
        ) < s.delivery_radius*1000 
        and s.is_active=true ;
        ",
        [CustomerId]),
    #{num_rows => NumRows, stores => Stores}.


link_store_to_order(OrderId, StoreId, IsPickup, IsDelivery, OrderComment) ->
    #{num_rows := N, result := [Order]} = 
    db_connector:extended_query(
        "
        update orders set store_id = $2, is_pickup = $3, is_delivery = $4, 
            time_200_customer_sent = now(), status_200_customer_sent = true,
            customer_note = $5 
        where order_id = $1
        returning *
        ",
    [OrderId, StoreId, IsPickup, IsDelivery, OrderComment]),
    #{ num_rows => N, order => Order}.

payment_made(OrderId, IsPaymentCash, IsPaymentOnline, IsPaymentCredit, Amount) ->
    #{num_rows := N, result := [Order]} = 
    db_connector:extended_query(
        "
        update orders set time_600_payment_made = now(), 
            status_600_payment_made = true, status_500_customer_received = true, status_400_store_fulfilled = true,
            payment_cash = $2, payment_online = $3, payment_credit = $4, price = $5 
        where order_id = $1
        returning *
        ",
    [OrderId, IsPaymentCash, IsPaymentOnline, IsPaymentCredit, Amount]),
    #{ num_rows => N, order => Order}.

% log_in_store(FirebaseUid, FcmToken, MobileNumber) -> 
    % #{num_rows := NumRows} = db_connector:extended_query(
        % "
        % insert into store(fcm_token, mobile_number, firebase_auth_uid) 
        % values($1, $2, $3)
        % on conflict (firebase_auth_uid)
        % do update
        % set fcm_token = excluded.fcm_token 
        % where (
            % store.fcm_token != excluded.fcm_token 
            % OR 
            % store.fcm_token IS NULL
        % )
        % ", 
        % [FcmToken, MobileNumber, FirebaseUid]),
    % NumRows.

log_in_store(FirebaseUid, MobileNumber) -> 
    #{num_rows := NumRows} = db_connector:extended_query(
        "
        insert into store(mobile_number, firebase_auth_uid) 
        values($1, $2)
        on conflict 
        do nothing
        ", 
        [MobileNumber, FirebaseUid]),
    NumRows.

update_store_fcm(FirebaseUid, FcmToken) -> 
    #{num_rows := NumRows} = db_connector:extended_query(
        "
        insert into store_fcm_tokens(fcm_token, firebase_auth_uid) 
        values($1, $2)
        on conflict 
        do nothing
        ", 
        [FcmToken, FirebaseUid]),
    NumRows.

update_store_name(StoreName, FireBaseUid) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update store set name = $1
        where firebase_auth_uid = $2
        ",
    [StoreName, FireBaseUid]),
    #{ num_rows => N}.

store_details_given_firebase_uid(FireBaseUid) ->
    #{ num_rows := N, result := [#{
        name := UserName, address_line1 := AddressLine1, 
        address_line2 := AddressLine2, city := City, 
        state := State, pincode := Pincode,
        latitude := Latitude, longitude := Longitude,
        offers_pickup := OffersPickup, offers_delivery := OffersDelivery,
        delivery_radius := DeliveryRadius, payment_online := PaymentOnline,
        payment_cash := PaymentCash, payment_credit := PaymentCredit, upi_id := UpiId
    }]} = db_connector:extended_query(
        "
        select name, address_line1, address_line2, city, state, pincode, latitude, longitude,
            offers_pickup, offers_delivery, delivery_radius, payment_online, payment_cash, payment_credit, upi_id
        from store 
        where firebase_auth_uid = $1
        ",
        [FireBaseUid]),
    #{
        num_rows => N, username => UserName, 
        address_line1 => AddressLine1, address_line2 => AddressLine2, 
        city => City, state => State, pincode => Pincode,
        latitude => Latitude, longitude => Longitude,
        offers_pickup => OffersPickup, offers_delivery => OffersDelivery,
        delivery_radius => DeliveryRadius, payment_online => PaymentOnline,
        payment_cash => PaymentCash, payment_credit => PaymentCredit, upi_id => UpiId
    }.

update_store_address(
    FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update store set 
            address_line1 = $2,
            address_line2 = $3,
            city = $4,
            state = $5,
            pincode = $6,
            latitude = $7,
            longitude = $8,
            geo_accuracy = $9
        where firebase_auth_uid = $1
        ",
    [FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, GeoAccuracy]),
    #{ num_rows => N}.

update_store_services(FireBaseUid, DeliveryService, PickupService, UpdatedRadius) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update store set 
            offers_delivery = $2,
            offers_pickup = $3,
            delivery_radius = $4
        where firebase_auth_uid = $1
        ",
    [FireBaseUid, DeliveryService, PickupService, UpdatedRadius]),
    #{ num_rows => N}.

update_store_payments(FireBaseUid, PaymentOnline, UpiId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update store set 
            payment_online = $2,
            upi_id = $3
        where firebase_auth_uid = $1
        ",
    [FireBaseUid, PaymentOnline, UpiId]),
    #{ num_rows => N}.

store_id_given_fbuid(FireBaseUid) ->
    #{result := [#{store_id := StoreId}]} = 
    db_connector:extended_query(
        "
        select store_id from store 
        where firebase_auth_uid = $1
        order by time_of_creation desc limit 1
        ",
        [FireBaseUid]),
    StoreId.

orders_given_store_id(StoreId) -> 
    #{num_rows := N, result := Orders} = 
    db_connector:extended_query(
        "
        select o.*,
            c.name as customer_name,
            c.address_line1 as customer_address_line1,
            c.address_line2 as customer_address_line2,
            c.city as customer_city,
            c.pincode as customer_pincode,
            c.mobile_number as customer_mobile_number,
            c.customer_id as customer_id
        from orders o
        left join customer c
        on o.customer_id = c.customer_id
        where o.store_id=$1
        ",
    [StoreId]),
    #{ num_rows => N, orders => Orders}.

update_order_item(OrderItemId, OrderItemPrice, OrderItemAvailable) ->
    #{num_rows := N, result := OrderItem} = 
    db_connector:extended_query(
        "
        update order_item set price = $2, available = $3
        where order_item_id = $1
        returning *
        ",
    [OrderItemId, OrderItemPrice, OrderItemAvailable]),
    #{ num_rows => N, result => OrderItem}.

save_order(OrderId, OrderDetail) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        insert into order_detail(order_id, data)
        values ($1, $2)
        on conflict (order_id)
        do update 
        set data = excluded.data, last_updated = now()
        where (order_detail.order_id = excluded.order_id)
        returning *
        ",
    [OrderId, OrderDetail]),

    #{num_rows := N1} = 
    db_connector:extended_query(
      "
      update orders
      set 
        status_150_customer_saved = true,
        time_150_customer_saved = now()
       where order_id = $1
       ",
      [OrderId]
     ),
    erlang:display(N1),
    case N1 of 
        1 -> #{ num_rows => N}
    end.

store_confirm_order(OrderId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update orders set time_300_store_checked = now(), 
            status_300_store_checked = true
        where order_id = $1
        ",
    [OrderId]),
    #{ num_rows => N}.

store_confirm_fulfil(OrderId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update orders set time_400_store_fulfilled = now(), 
            status_400_store_fulfilled = true
        where order_id = $1
        ",
    [OrderId]),
    #{ num_rows => N}.

store_confirm_payment(OrderId) ->
    #{num_rows := N} = 
    db_connector:extended_query(
        "
        update orders set time_700_payment_received = now(), 
            status_700_payment_received = true, status_600_payment_made = true,
            status_500_customer_received = true
        where order_id = $1
        ",
    [OrderId]),
    #{ num_rows => N}.

% todo - update to check in customers table that it is not an old customer
store_refer_customer(StoreId, CustomerName, CustomerNumber) -> 
    #{num_rows := NumRows} =
        db_connector:extended_query(
            "
            insert into customer_referred_by_store
                (store_id, customer_name, customer_mobile_number)
            values($1, $2, $3)
            on conflict (customer_mobile_number)
            do nothing
            "
        ,
        [StoreId, CustomerName, CustomerNumber]),
        #{num_rows => NumRows}.

store_delete_customer(StoreId, CustomerNumber) -> 
    #{num_rows := NumRows} =
        db_connector:extended_query(
            "
            delete from customer_referred_by_store
                where store_id = $1 and customer_mobile_number = $2
            "
        ,
        [StoreId, CustomerNumber]),
        #{num_rows => NumRows}.

referred_customers_given_store(StoreId) ->
    #{num_rows := N, result := Customers} = 
        db_connector:extended_query(
            "
            select customer_mobile_number, customer_name
            from customer_referred_by_store
            where store_id = $1
            ",
        [StoreId]),
    #{ num_rows => N, customers => Customers}.

customers_given_store(StoreId) ->
    #{num_rows := N, result := Customers} = 
        db_connector:extended_query(
            "
            select cx.customer_name, cx.customer_mobile_number 
            from customer_referred_by_store cx 
            where store_id = $1
            union
            select c.name as customer_name, c.mobile_number as customer_mobile_number 
            from orders o 
                join customer c 
                on o.customer_id = c.customer_id 
            where o.store_id=$1;
            ",
        [StoreId]),
    #{ num_rows => N, customers => Customers}.


% store_fcm_given_id(StoreId) ->
    % #{result := [Result]} = 
        % db_connector:extended_query(
            % "
            % select fcm_token from store
            % where store_id = $1
            % ",
        % [StoreId]),
    % #{ fcm_token := FcmToken } = Result,
    % FcmToken.
 
store_fcms_given_id(StoreAuthUid) ->
    #{result := Result} = 
        db_connector:extended_query(
            "
            select sft.fcm_token
                from store_fcm_tokens sft
                join
                store s
                on s.firebase_auth_uid = sft.firebase_auth_uid
            where s.store_id = $1
            ",
        [StoreAuthUid]),
    % #{ fcm_token := FcmTokens } = Result,
    % FcmTokens.
    Result.

customer_fcm_given_order_id(OrderId) ->
    #{result := [Result]} = 
        db_connector:extended_query(
            "
            select c.fcm_token 
            from 
            orders o join customer c 
            on 
            o.customer_id=c.customer_id 
            where 
            o.order_id=$1;
            ",
        [OrderId]),
    #{ fcm_token := FcmToken } = Result,
    FcmToken.

store_name_given_order_id(OrderId) ->
    #{result := [Result]} = 
        db_connector:extended_query(
            "
            select s.name 
            from 
            orders o join store s 
            on 
            o.store_id=s.store_id 
            where 
            o.order_id=$1
            ",
        [OrderId]),
    #{ name := StoreName } = Result,
    StoreName.

get_states_list() ->
    #{num_rows := N, result := Result} =
        db_connector:simple_query("
            select distinct state from store
            where state <> 'Kashmir ' and
                state <> 'Lakshadeep' 
        "),
        #{num_rows => N, result => Result}.
    
get_stores_in_state(State) ->
    #{num_rows := N, result := Result} =
        db_connector:extended_query("
            select s.name, s.mobile_number, s.address_line1, 
                concat (date_part('year', s.time_of_creation ), '-', 
                    date_part('month', s.time_of_creation ), '-', 
                    date_part('day', s.time_of_creation ), ' at ', 
                    date_part('hour', s.time_of_creation ), ':', 
                    date_part('minute', s.time_of_creation )
                    ) as onboarded_time
            from store s where s.state = $1 and s.is_active = true;
        ", [State]),
        #{num_rows => N, result => Result}.

 get_orders_in_state(State) ->
    #{num_rows := N, result := Result} =
        db_connector:extended_query("
            select 
                c.name as customer_name, 
                c.mobile_number as customer_number, 
                s.name as store_name, 
                o.order_id, 
                concat (date_part('year', o.time_200_customer_sent), '-', 
                    date_part('month', o.time_200_customer_sent), '-', 
                    date_part('day', o.time_200_customer_sent), ' at ', 
                    date_part('hour', o.time_200_customer_sent), ':', 
                    date_part('minute', o.time_200_customer_sent)
                    ) as t1_order_sent, 

                concat (date_part('year', o.time_300_store_checked ), '-', 
                    date_part('month', o.time_300_store_checked ), '-', 
                    date_part('day', o.time_300_store_checked ), ' at ', 
                    date_part('hour', o.time_300_store_checked ), ':', 
                    date_part('minute', o.time_300_store_checked )
                    ) as t2_order_checked, 
                concat (date_part('year', o.time_400_store_fulfilled ), '-', 
                    date_part('month', o.time_400_store_fulfilled ), '-', 
                    date_part('day', o.time_400_store_fulfilled ), ' at ', 
                    date_part('hour', o.time_400_store_fulfilled ), ':', 
                    date_part('minute', o.time_400_store_fulfilled )
                    ) as t3_order_fulfilled,
                concat (date_part('year', o.time_600_payment_made ), '-', 
                    date_part('month', o.time_600_payment_made  ), '-', 
                    date_part('day', o.time_600_payment_made  ), ' at ', 
                    date_part('hour', o.time_600_payment_made  ), ':', 
                    date_part('minute', o.time_600_payment_made  )
                    ) as t4_payment_made, 
                concat (date_part('year', o.time_700_payment_received ), '-', 
                    date_part('month', o.time_700_payment_received ), '-', 
                    date_part('day', o.time_700_payment_received ), ' at ', 
                    date_part('hour', o.time_700_payment_received ), ':', 
                    date_part('minute', o.time_700_payment_received )
                    ) as t5_payment_received 
            from 
                orders o 
                join store s 
                    on s.store_id = o.store_id 
                join customer c 
                    on c.customer_id = o.customer_id 
                where s.state=$1 and c.mobile_number <> '+911234567890' 
                    and c.mobile_number <> '+919438117072' 
                    and s.store_id <> 313 and s.store_id <> 181 and s.store_id <> 303
                    and s.store_id <> 192 and s.store_id <> 200
            order by o.time_200_customer_sent desc
            ", [State]),
        #{num_rows => N, result => Result}.
 
get_customers_referred_by_stores_in_state(State) ->
    #{num_rows := N, result := Result} = 
        db_connector:extended_query("
        select 
            --crs.created_time as date_added, 
            concat (date_part('year', crs.created_time ), '-', 
                date_part('month', crs.created_time ), '-', 
                date_part('day', crs.created_time ), ' at ', 
                date_part('hour', crs.created_time ), ':', 
                date_part('minute', crs.created_time )
                ) as date_added, 
            crs.customer_name, 
            customer_mobile_number as customer_number, 
            s.name as store 
        from 
            customer_referred_by_store crs 
            join store s 
                on s.store_id = crs.store_id 
                where s.state = $1
        order by s.name, crs.created_time desc
        ", [State]),
    #{num_rows => N, result => Result}.

get_users_in_state(State) ->
    #{num_rows := N, result := Result} = 
        db_connector:extended_query("
            with 
            x as (
                select s1.name as store_name, s1.store_id as store_id 
                from store s1 
                    join 
                        customer_referred_by_store crs 
                        on crs.store_id = s1.store_id
                ) 
            select 
                distinct on (c.name, c.time_of_creation)
                concat (date_part('year', c.time_of_creation ), '-', 
                date_part('month', c.time_of_creation ), '-', 
                date_part('day', c.time_of_creation ), ' at ', 
                date_part('hour', c.time_of_creation ), ':', 
                date_part('minute', c.time_of_creation )
                ) as date_joined, 
                c.name as name, c.mobile_number as number, c.city as city, 
                x.store_name as referrer_store

            from customer c 
                left join customer_referred_by_store crs
                    on crs.customer_mobile_number = c.mobile_number
                left join x
                    on x.store_id = crs.store_id
            where c.mobile_number <> '+911234567890' and c.mobile_number <> '+919876543210' and c.mobile_number <> '+919438117072' and c.mobile_number <> '+919437694897' 
                and c.state = $1 
            order by c.name, c.time_of_creation, c.city 
        ", [State]),
    #{num_rows => N, result => Result}.

%for stores that signed up with two different numbers
orders_by_store_2(StoreId1, StoreId2) ->
    #{num_rows := N, result := Result} =
        db_connector:extended_query("
            select o.order_id, 
                concat (date_part('year', o.time_200_customer_sent ), '-', 
                    date_part('month', o.time_200_customer_sent ), '-', 
                    date_part('day', o.time_200_customer_sent ), ' at ', 
                    date_part('hour', o.time_200_customer_sent ), ':', 
                    date_part('minute', o.time_200_customer_sent )
                    ) as time_of_order,
                i.name, i.quantity, i.price
            from 
            orders o 
                join order_item i 
                    on i.order_id = o.order_id 
            where o.store_id = $1 or o.store_id = $2 
            order by o.time_200_customer_sent ;
        ", [StoreId1, StoreId2]),
        #{num_rows => N, result => Result}.

%for stores that have only one account
orders_by_store_1(StoreId1) ->
    #{num_rows := N, result := Result} =
        db_connector:extended_query("
            select o.order_id, 
                concat (date_part('year', o.time_200_customer_sent ), '-', 
                    date_part('month', o.time_200_customer_sent ), '-', 
                    date_part('day', o.time_200_customer_sent ), ' at ', 
                    date_part('hour', o.time_200_customer_sent ), ':', 
                    date_part('minute', o.time_200_customer_sent )
                    ) as time_of_order,
                i.name, i.quantity, i.price
            from 
            orders o 
                join order_item i 
                on i.order_id = o.order_id 
            where o.store_id = $1 
            order by o.time_200_customer_sent ;
        ", [StoreId1]),
        #{num_rows => N, result => Result}.

%add loyalty code to customer 
add_loyalty_code_customer(FireBaseUid, Object) ->
    io:format("~n adding loyalty code VALUE ~n ~p ~n", [Object]),

    % #{num_rows := NumRows, result := [#{order_item_id := OrderItemId}]} =

    #{num_rows := NumRows, result := [#{loyalty_code := LoyaltyCode}]} =
    db_connector:extended_query("
        update customer set loyalty_code = loyalty_code || $2::jsonb 
        where firebase_auth_uid = $1
        returning loyalty_code
        ",
        % [C, jsx:encode('{Category: LoyaltyCode}')]
        % [C, jsx:encode({Category: LoyaltyCode})]
        % [C, jsx:encode(Value)]
        [FireBaseUid, Object]
        % [C, '{Category: LoyaltyCode}']
    ),
    #{num_rows => NumRows, loyalty_code => LoyaltyCode}.

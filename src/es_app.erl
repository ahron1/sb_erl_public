-module(es_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).
-export([reload_routes/0]).

-on_reload(reload_routes/0).

start(_Type, _Args) ->

%	{ok, FcmPidStorebhaiManager} = fcm:start_pool_with_json_service_file(
%		fcm_storebhai_manager, "/var/www/backend/sb_erl/firebase-adminsdk-storebhai-manager.json"
%	),
%	io:format("~n STOREBHAI MANAGER FCM POOL STARTED PID ~n ~p~n", [FcmPidStorebhaiManager]),
%
%	{ok, FcmPidStorebhai} = fcm:start_pool_with_json_service_file(
%		fcm_storebhai, "/var/www/backend/sb_erl/firebase-adminsdk-store-bhai.json"
%	),
%	io:format("~n STOREBHAI FCM POOL STARTED PID ~n ~p~n", [FcmPidStorebhai]),

	% {ok, FcmPid} = fcm:start_pool_with_json_service_file(test, "/var/www1/backend/es/store-.json"),
	% io:format("~n FCM POOL STARTED PID ~n ~p~n", [FcmPid]),

	Dispatch = make_dispatch(),

	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),
	es_sup:start_link().

make_dispatch() -> 
	cowboy_router:compile([
		{'_', [
			{"/", hello_handler, []}
			,{"/customer_account", customer_account_handler, []}
			,{"/get_customer_details", get_customer_details_handler, []}
			,{"/update_customer_name", update_customer_name_handler, []}
			,{"/update_customer_address", update_customer_address_handler, []}
			,{"/update_customer_profile", update_customer_profile_handler, []}
			,{"/get_orders", get_orders_handler, []}
			,{"/add_order", add_order_handler, []}
			,{"/save_order", save_order_handler, []}
			,{"/delete_order", delete_order_handler, []}
			,{"/send_order", send_order_handler, []}
			,{"/payment_made", payment_made_handler, []}
			,{"/get_order_items", get_order_items_handler, []}
			,{"/get_order_details", get_order_details_handler, []}
			,{"/delete_order_item", delete_order_item_handler, []}
			,{"/add_order_item", add_order_item_handler, []}
			,{"/get_stores", get_stores_handler, []}
			,{"/get_default_store", get_default_store_handler, []}

			,{"/store_account", store_account_handler, []}
			,{"/update_store_name", update_store_name_handler, []}
			,{"/get_store_details", get_store_details_handler, []}
			,{"/update_store_address", update_store_address_handler, []}
			,{"/update_store_services", update_store_services_handler, []}
			,{"/update_store_payments", update_store_payments_handler, []}
			,{"/get_store_orders", get_store_orders_handler, []}
			,{"/get_store_order_items", get_store_order_items_handler, []}
			,{"/update_store_order_item", update_store_order_item_handler, []}
			,{"/store_confirm_order", store_confirm_order_handler, []}
			,{"/store_confirm_payment", store_confirm_payment_handler, []}
			,{"/store_confirm_fulfil", store_confirm_fulfil_handler, []}
			,{"/store_add_customer", store_add_customer_handler, []}
			,{"/store_delete_customer", store_delete_customer_handler, []}
			% ,{"/get_store_customers", get_customers_referred_by_store_handler, []}
			,{"/get_store_customers", get_store_customers_handler, []}

			,{"/get_states", get_states_handler, []}
			,{"/get_stores_in_state", get_stores_in_state_handler, []}
			,{"/get_orders_in_state", get_orders_in_state_handler, []}
			,{"/get_users_in_state", get_users_in_state_handler, []}
			,{"/get_customers_referred_in_state", get_customers_referred_in_state_handler, []}

			,{"/get_dashboard_bee_my_shopper", get_dashboard_bee_my_shopper_handler, []}

			,{"/add_loyalty_code_customer", add_loyalty_code_customer_handler, []}

		]}
]).

reload_routes() -> 
	cowboy:set_env(https, dispatch, make_dispatch()).

stop(_State) ->
	ok = cowboy:stop_listener(http).

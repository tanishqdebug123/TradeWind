from django.urls import path
from . import views

urlpatterns = [
    path('user-portfolio/', views.user_portfolio),
    path('user-transactions/', views.user_transactions),
    path('stock-transactions/', views.stock_transactions),
    path('top-holders/', views.top_holders),
    path('transactions-in-range/', views.transactions_in_range),
    path('register/', views.register_user),
    path('login/', views.login_user),
    path('user-name/', views.user_name),
    path('watchlist/<int:user_id>/', views.get_watchlist),
    path('watchlist/add/', views.add_to_watchlist),
    path('watchlist/remove/<str:symbol>/', views.remove_from_watchlist),
    path('orders/<int:user_id>/', views.get_orders),
    path('orders/place/', views.place_order),
    path('portfolio/<int:user_id>/', views.get_portfolio),    
    path("profile/", views.get_profile),
]

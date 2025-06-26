from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Stock, Watchlist, Order

class StockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stock
        fields = '__all__'

class WatchlistSerializer(serializers.ModelSerializer):
    stock = StockSerializer(read_only=True)

    class Meta:
        model = Watchlist
        fields = ['id', 'stock']

class OrderSerializer(serializers.ModelSerializer):
    stock = StockSerializer(read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'stock', 'order_type', 'quantity', 'price_at_order', 'created_at']

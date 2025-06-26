from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db import connection
from django.contrib.auth.hashers import make_password, check_password
from rest_framework import status
from .models import Watchlist, Order, Stock
from .serializers import WatchlistSerializer, OrderSerializer, StockSerializer
from django.contrib.auth.models import User

@api_view(['POST'])
def login_user(request):
    user_id = request.data.get('userid')
    password = request.data.get('password')

    with connection.cursor() as cursor:
        cursor.execute("SELECT Name, Password FROM User WHERE UserID = %s", [user_id])
        result = cursor.fetchone()

        if not result:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        name, stored_hash = result
        if check_password(password, stored_hash):
            return Response({"message": "Login successful", "userid": user_id, "name": name})
        else:
            return Response({"error": "Incorrect password"}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
def register_user(request):
    user_id = request.data.get('userid')
    name = request.data.get('name')
    email = request.data.get('email')
    raw_password = request.data.get('password')

    try:
        with connection.cursor() as cursor:
            # Hash the password before storing
            hashed_password = make_password(raw_password)

            cursor.execute("""
                INSERT INTO User (UserID, Name, Email, Password, Virtual_Balance)
                VALUES (%s, %s, %s, %s, %s)
            """, [user_id, name, email, hashed_password, 1000.00])

        return Response({"message": "User registered successfully"})

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# Helper to run raw SQL and return results as list of dicts
def run_query(query, params, description):
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        columns = [col[0] for col in cursor.description]
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
    return {"query_info": description, "results": rows}


@api_view(['POST'])
def user_name(request):
    user_id = request.data.get('userid')
    query = """
        SELECT Name
        FROM User
        WHERE UserID = %s
    """
    try:
        with connection.cursor() as cursor:
            cursor.execute(query, [user_id])
            result = cursor.fetchone()
            print("## DEBUG: ", result)
            if result:
                return Response({"username": result[0]})
            else:
                return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def user_portfolio(request):
    user_id = request.data.get('userid')
    query = """
        SELECT p.UserID, u.Name, s.Symbol, s.Stock_Name, p.Quantity, s.Current_Price,
               (p.Quantity * s.Current_Price) AS Current_Value
        FROM Portfolio p
        JOIN User u ON p.UserID = u.UserID
        JOIN Stock s ON p.StockID = s.StockID
        WHERE p.UserID = %s
    """
    return Response(run_query(query, [user_id], f"Portfolio for User ID: {user_id}"))


@api_view(['POST'])
def user_transactions(request):
    user_id = request.data.get('userid')
    query = """
        SELECT t.TransactionID, t.StockID, s.Symbol, t.Price, t.Quantity, t.Buy_Sell, 
               t.Status, t.Date_Time
        FROM Transaction t
        JOIN Stock s ON t.StockID = s.StockID
        WHERE t.UserID = %s
        ORDER BY t.Date_Time DESC
    """
    return Response(run_query(query, [user_id], f"Transactions for User ID: {user_id}"))


@api_view(['POST'])
def stock_transactions(request):
    stock_id = request.data.get('stockid')
    query = """
        SELECT t.TransactionID, u.Name, t.Price, t.Quantity, t.Buy_Sell, t.Status, t.Date_Time
        FROM Transaction t
        JOIN User u ON t.UserID = u.UserID
        WHERE t.StockID = %s
        ORDER BY t.Date_Time DESC
    """
    return Response(run_query(query, [stock_id], f"Transactions for Stock ID: {stock_id}"))


@api_view(['POST'])
def top_holders(request):
    stock_id = request.data.get('stockid')
    query = """
        SELECT p.UserID, u.Name, s.Symbol, s.Stock_Name, p.Quantity
        FROM Portfolio p
        JOIN User u ON p.UserID = u.UserID
        JOIN Stock s ON p.StockID = s.StockID
        WHERE p.StockID = %s
        ORDER BY p.Quantity DESC
        LIMIT 10
    """
    return Response(run_query(query, [stock_id], f"Top holders of Stock ID: {stock_id}"))


@api_view(['POST'])
def transactions_in_range(request):
    user_id = request.data.get('userid')
    start_date = request.data.get('start_date')
    end_date = request.data.get('end_date')
    query = """
        SELECT t.TransactionID, t.StockID, s.Symbol, t.Price, t.Quantity, t.Buy_Sell,
               t.Status, t.Date_Time
        FROM Transaction t
        JOIN Stock s ON t.StockID = s.StockID
        WHERE t.UserID = %s AND DATE(t.Date_Time) BETWEEN %s AND %s
        ORDER BY t.Date_Time DESC
    """
    return Response(run_query(query, [user_id, start_date, end_date], f"Transactions for User ID: {user_id} between {start_date} and {end_date}"))

# Watchlist GET
@api_view(['GET'])
def get_watchlist(request, user_id):
    watchlist = Watchlist.objects.filter(user__id=user_id)
    serializer = WatchlistSerializer(watchlist, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def add_to_watchlist(request):
    #print("Received data:", request.data)  # Add this line
    user_id = request.data.get('user_id')
    symbol = request.data.get('symbol')

    try:
        user = User.objects.get(id=user_id)
        stock = Stock.objects.get(symbol=symbol.upper())  # Make case-insensitive
        Watchlist.objects.get_or_create(user=user, stock=stock)
        return Response({"message": "Stock added to watchlist."})
    except Exception as e:
        #print("Error:", str(e))  # Add this too
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def remove_from_watchlist(request, symbol):
    user_id = request.query_params.get("user_id") or request.data.get("user_id")

    if not user_id:
        return Response({'error': 'Missing user ID'}, status=400)

    try:
        stock = Stock.objects.get(symbol=symbol)
        watchlist_item = Watchlist.objects.get(user_id=user_id, stock=stock)
        watchlist_item.delete()
        return Response({'message': 'Removed from watchlist'}, status=200)
    except Stock.DoesNotExist:
        return Response({'error': 'Stock not found'}, status=404)
    except Watchlist.DoesNotExist:
        return Response({'error': 'Item not in watchlist'}, status=404)
    
# Orders GET
@api_view(['GET'])
def get_orders(request, user_id):
    orders = Order.objects.filter(user__id=user_id).order_by('-created_at')
    serializer = OrderSerializer(orders, many=True)
    return Response(serializer.data)

# Orders PLACE
@api_view(['POST'])
def place_order(request):
    user_id = request.data.get('user_id')
    symbol = request.data.get('symbol')
    order_type = request.data.get('order_type')
    quantity = int(request.data.get('quantity'))

    try:
        user = User.objects.get(id=user_id)
        stock = Stock.objects.get(symbol=symbol)
        price = stock.current_price

        order = Order.objects.create(
            user=user,
            stock=stock,
            order_type=order_type.upper(),
            quantity=quantity,
            price_at_order=price
        )
        return Response({"message": "Order placed successfully."})
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# Portfolio GET (calculated from orders)
@api_view(['GET'])
def get_portfolio(request, user_id):
    orders = Order.objects.filter(user__id=user_id)
    holdings = {}

    for order in orders:
        sym = order.stock.symbol
        qty = order.quantity if order.order_type == 'BUY' else -order.quantity
        if sym not in holdings:
            holdings[sym] = 0
        holdings[sym] += qty

    # Get live prices
    data = []
    for symbol, quantity in holdings.items():
        if quantity == 0:
            continue
        stock = Stock.objects.get(symbol=symbol)
        data.append({
            'symbol': symbol,
            'quantity': quantity,
            'current_price': stock.current_price,
            'total_value': round(quantity * stock.current_price, 2)
        })

    return Response(data)

@api_view(['POST'])
def get_profile(request):
    user_id = request.data.get('userid')
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT UserID, Name, Email, Password, Virtual_Balance
                FROM User
                WHERE UserID = %s
            """, [user_id])
            result = cursor.fetchone()
            if result:
                keys = ["userid", "name", "email", "password", "virtual_balance"]
                return Response(dict(zip(keys, result)))
            else:
                return Response({"error": "User not found"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=400)

@api_view(['POST'])
def place_order(request):
    user_id = request.data.get('user_id')
    symbol = request.data.get('symbol')
    order_type = request.data.get('order_type').upper()  
    quantity = int(request.data.get('quantity'))
    order_price = float(request.data.get('price'))  

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT StockID, Current_Price FROM Stock WHERE Symbol = %s", [symbol])
            stock_row = cursor.fetchone()
            if not stock_row:
                return Response({"error": "Invalid stock symbol"}, status=400)

            stock_id, current_price = stock_row
            margin_low = current_price * 0.985
            margin_high = current_price * 1.015

            if not (margin_low <= order_price <= margin_high):
                return Response({"error": "Order price outside ±1.5% range of current market price"}, status=400)

            total_cost = order_price * quantity

            if order_type == 'BUY':
                cursor.execute("SELECT Virtual_Balance FROM User WHERE UserID = %s", [user_id])
                balance = cursor.fetchone()[0]

                if total_cost > balance:
                    return Response({"error": "Insufficient funds"}, status=400)

                cursor.execute("""
                    UPDATE User SET Virtual_Balance = Virtual_Balance - %s
                    WHERE UserID = %s
                """, [total_cost, user_id])

                cursor.execute("""
                    SELECT PortfolioID, Quantity FROM Portfolio
                    WHERE UserID = %s AND StockID = %s
                """, [user_id, stock_id])
                port = cursor.fetchone()

                if port:
                    portfolio_id, existing_qty = port
                    cursor.execute("""
                        UPDATE Portfolio SET Quantity = Quantity + %s
                        WHERE PortfolioID = %s AND StockID = %s
                    """, [quantity, portfolio_id, stock_id])
                else:
                    portfolio_id = int(f"{user_id}{stock_id}")
                    cursor.execute("""
                        INSERT INTO Portfolio (PortfolioID, UserID, StockID, Quantity)
                        VALUES (%s, %s, %s, %s)
                    """, [portfolio_id, user_id, stock_id, quantity])

                cursor.execute("""
                    INSERT INTO Transaction (UserID, StockID, PortfolioID, Quantity, Price, Buy_Sell, Status, Remarks)
                    VALUES (%s, %s, %s, %s, %s, 'Buy', 'EXECUTED', 'N/A')
                """, [user_id, stock_id, portfolio_id, quantity, order_price])

            elif order_type == 'SELL':
                cursor.execute("""
                    SELECT PortfolioID, Quantity FROM Portfolio
                    WHERE UserID = %s AND StockID = %s
                """, [user_id, stock_id])
                port = cursor.fetchone()

                if not port or port[1] < quantity:
                    return Response({"error": "Insufficient stock holdings"}, status=400)

                portfolio_id, current_qty = port

                new_qty = current_qty - quantity
                if new_qty == 0:
                    cursor.execute("""
                        DELETE FROM Portfolio
                        WHERE PortfolioID = %s AND StockID = %s
                    """, [portfolio_id, stock_id])
                else:
                    cursor.execute("""
                        UPDATE Portfolio SET Quantity = %s
                        WHERE PortfolioID = %s AND StockID = %s
                    """, [new_qty, portfolio_id, stock_id])

                cursor.execute("""
                    UPDATE User SET Virtual_Balance = Virtual_Balance + %s
                    WHERE UserID = %s
                """, [total_cost, user_id])

                cursor.execute("""
                    INSERT INTO Transaction (UserID, StockID, PortfolioID, Quantity, Price, Buy_Sell, Status, Remarks)
                    VALUES (%s, %s, %s, %s, %s, 'Sell', 'EXECUTED', 'N/A')
                """, [user_id, stock_id, portfolio_id, quantity, order_price])

            else:
                return Response({"error": "Invalid order type"}, status=400)

        return Response({"message": "Order placed and processed successfully."})

    except Exception as e:
        return Response({"error": str(e)}, status=500)

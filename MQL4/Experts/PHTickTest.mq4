//+------------------------------------------------------------------+
//|                                                   PHTickTest.mq4 |
//|                                                      HearMonster |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "HearMonster"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#ifndef _logger
   #include <PHLogger.mqh>
#endif

#ifndef _custom_types
   #include <PH Custom Types.mqh>
#endif 

#include <PHStickyTimepiece.mqh>
//#include <PHTradingExpert.mqh>
#include <PH OrderManagement2.mqh>
//#include <PHStatistics.mqh>
//#include <BarOpenEvent.mqh>


//Global variables
PHStickyTimepiece myTimepiece();
//PHTradingExpert myTradingExpert( "" );
PHOrderManagement2 myOM();
//PHStatistics myStats();

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
  
   //--- create timer
   EventSetTimer(1);

   myLogger.logINFO( "WindowExpertName: " + WindowExpertName() ) 

   myLogger.logINFO( "ChartPeriod: " + string( ChartPeriod( 0 ) ) );  // ChartPeriod( 0 ) = Current chart. Returns period (in mins)
   myLogger.logINFO( "ChartPeriod>>EnumToString: " + EnumToString( ChartPeriod( 0 ) ) ); 

   myLogger.logINFO( "ChartSymbol: " + ChartSymbol( 0 ) );  // ChartSymbol( 0 ) = Current chart. Returns string
   myLogger.logINFO( "TimeLocal: " + string( TimeLocal() ));         // returns a string ("2014.03.05 15:46:58") with #property strict, returns a datetime ("1394034418") without #property strict

      PH_FX_PAIRS eVal = -1;
      PH_FX_PAIRS eSymbol = StringToEnum( Symbol(), eVal );
      PH_ORDER_TYPES eMyOrderTypeCode = ORDER_BUY;
      PH_ENTRY_REASONS eReasonOpenType = ENTRY_RANDOMCOINFLIP;
      PHPercent oPercentageOfEquityToRisk( 1 );
      bool isFakeTrade = false;
      
      myOM.openTradeAtMarket( eSymbol, eMyOrderTypeCode, eReasonOpenType, oPercentageOfEquityToRisk, isFakeTrade );


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   //--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
   
   myLogger.logINFO(  
        StringConcatenate( "New Tick Appears (Period: ", Period(), ") >>> Bid: ", DoubleToStr( Bid, 5 ), 
        ", TimeCurrent(): ", TimeToStr( TimeCurrent(), TIME_DATE|TIME_SECONDS) ) );
        //, ", GetTickCount() ", GetTickCount() ) );

   datetime tTimeframeForNewM1Tick = iTime( Symbol(), PERIOD_M1, 0 );
   myLogger.logDEBUG( "The M1 timeframe for *this* tick " + string( tTimeframeForNewM1Tick ) );

   datetime tTimeframeForNewH1Tick = iTime( Symbol(), PERIOD_H1, 0 );
   myLogger.logDEBUG( "The H1 timeframe for *this* tick " + string( tTimeframeForNewH1Tick ) );

   datetime tTimeframeForNewD1Tick = iTime( Symbol(), PERIOD_D1, 0 );
   myLogger.logDEBUG( "The D1 timeframe for *this* tick " + string( tTimeframeForNewD1Tick ) );

   if ( myTimepiece.isANewMinutelyTick( "" ) ) {
      myLogger.logINFO( "This marks a new Minutely Tick/Bar Open!  Now go do some Minutely-based stuff..." );
      // ...
      
      //IS SUFFICIENT MARGIN AVAILABLE?  (Push this work into OrderManagement)
      //myLogger.logINFO( StringConcatenate( "Sufficient Margin?: ", myOM.isSufficientMarginAvailable( OP_BUY, Symbol(), 0.1 ) ) );
      
      /*
      myTradingExpert.OrdersAccounting1();
      myTradingExpert.TradingCriteria2();
      myTradingExpert.CloseOrders3();
      myTradingExpert.CalcOrderSize4();
      myTradingExpert.CreateMarketOrder5();
        */ 
      string sSymbol = Symbol();
/*
      string sSymbol = Symbol();
      PH_ORDER_TYPES eMyOrderTypeCode = ORDER_BUY;
      PH_ENTRY_REASONS eReasonOpenType = ENTRY_RANDOMCOINFLIP;
      double dPercentageOfEquityToRisk = 1;
      bool isFakeTrade = false;
      
      myOM.openTradeAtMarket( eSymbol, eMyOrderTypeCode, eReasonOpenType, dPercentageOfEquityToRisk, isFakeTrade );
*/
   } //end if Minutely Tick
   

   if ( myTimepiece.isANewHourlyTick( "" ) ) {
         myLogger.logINFO( "This marks a new Hourly Tick/Bar Open!  Now go do some Hourly-based stuff..." );
         // ...
   } //end if Hourly Tick
   
   if ( myTimepiece.isANewDaylyTick( "" ) ) {
         myLogger.logINFO( "This marks a new Dayly Tick/Bar Open!  Now go do some Dayly-based stuff..." );
         // ...
   } //end if Dayly Tick

   if ( myTimepiece.isANewWeeklyTick( "" ) ) {
         myLogger.logINFO( "This marks a new Weekly Tick/Bar Open!  Now go do some Weekly-based stuff..." );
         // ...
   } //end if Weekly Tick

/*

   if ( myTimepiece.isANewHourlyTick( "" ) ) {
      //start::daily post-trade logic
      myLogger.logDEBUG( StringConcatenate( "Calculate Stats..." ) );
      myStats.CalcStatsForAllOpenOrders();   //Calculates 'MAE' and 'Peak Profit' for each open trade. Also build 'Open Order Book'
      myOM.ManageOpenTrades();   //Calculates 'revised Stop Loss' for each open trade
      setTrendCycleTidemark.TH();
   } //endif
*/



  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
   myLogger.fileFlush();
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                 TickTest2020.mq4 |
//|                                                      HearMonster |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "HearMonster"
#property link      ""
#property version   "1.00"
#property strict

#include <PHLogger2020.mqh>       //include log file code

//<<<Global Variables>>>
PHLogger2020 myTraceLogger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- create timer (used for flushing the log file)
   EventSetTimer(2);

   //Open Log File (Overwrite mode, disable flush)
   myTraceLogger.logOpen(  "TickTest", true, -1 );
   myTraceLogger.logWrite( LOG_OFF, "Starting Logging...", LOG_OFF);
   
   //---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- destroy timer
   EventKillTimer();
   
   //Close Log File
   myTraceLogger.logClose( false );
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int kFunctionLoggingLevel = LOG_DEBUG;
   string sLogPrefix = "TickTest2020::OnTick::";

      myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "New Tick Appears (Period: ", Period(), ") >>> Bid: ", DoubleToStr( Bid, 5 ), ", TimeCurrent(): ", TimeToStr( TimeCurrent(), TIME_DATE|TIME_SECONDS), ", GetTickCount() ", GetTickCount() ), kFunctionLoggingLevel );

      datetime tTimeframeForTick = iTime( Symbol(), PERIOD_M1, 0 );
      myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "The timeframe for *this* tick ", tTimeframeForTick ), kFunctionLoggingLevel );      
      
/*
      if( isTheSameMinutelyTick() ) {
         myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Minute tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
      }

      if( isTheSameDailyTick() ) {
         myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Daily tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
      }

      if( isTheSameWeeklyTick() ) {
         myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Weekly tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
      }

      if( isTheSameHourlyTick() ) {
         myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Hourly tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
      }
*/      
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   myTraceLogger.logFlush();
   
  }
//+------------------------------------------------------------------+






bool isTheSameMinutelyTick() {
   int kFunctionLoggingLevel = LOG_DEBUG;
   string sLogPrefix = "TickTest2020::isMinutelyTick::";

   static datetime tLastTimeframeSeen; 
   datetime tTimeframeForNewM1Tick = iTime( Symbol(), PERIOD_M1, 0 );
   bool isMinutelyTick = false;
   
   if ( (tLastTimeframeSeen != tTimeframeForNewM1Tick) && (tLastTimeframeSeen != 0)) {
      isMinutelyTick = true;
   }
   tLastTimeframeSeen = tTimeframeForNewM1Tick;

   myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "One Minutely tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
   return( isMinutelyTick );
}


bool isTheSameWeeklyTick() {
   int kFunctionLoggingLevel = LOG_OFF;
   string sLogPrefix = "TickTest2020::isWeeklyTick::";

   static datetime tLastTimeframeSeen; 
   datetime tTimeframeForNewW1Tick = iTime( Symbol(), PERIOD_W1, 0 );
   bool isWeeklyTick = false;
   
   if ( (tLastTimeframeSeen != tTimeframeForNewW1Tick) && (tLastTimeframeSeen != 0)) {
      isWeeklyTick = true;
   }
   tLastTimeframeSeen = tTimeframeForNewW1Tick;

   myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Weekly tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
   return( isWeeklyTick );
}


bool isTheSameHourlyTick() {
   int kFunctionLoggingLevel = LOG_OFF;
   string sLogPrefix = "TickTest2020::isHourlyTick::";

   static datetime tLastTimeframeSeen; 
   datetime tTimeframeForNewH1Tick = iTime( Symbol(), PERIOD_H1, 0 );
   bool isHourlyTick = false;
   
   if ( (tLastTimeframeSeen != tTimeframeForNewH1Tick) && (tLastTimeframeSeen != 0)) {
      isHourlyTick = true;
   }
   tLastTimeframeSeen = tTimeframeForNewH1Tick;

   myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Hourly tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
   return( isHourlyTick );
}

bool isTheSameDailyTick() {
   int kFunctionLoggingLevel = LOG_OFF;
   string sLogPrefix = "TickTest2020::isDailyTick::";

   static datetime tLastTimeframeSeen; 
   datetime tTimeframeForNewD1Tick = iTime( Symbol(), PERIOD_D1, 0 );
   bool isDailyTick = false;
   
   if ( (tLastTimeframeSeen != tTimeframeForNewD1Tick) && (tLastTimeframeSeen != 0)) {
      isDailyTick = true;
   }
   tLastTimeframeSeen = tTimeframeForNewD1Tick;

   myTraceLogger.logWrite( LOG_DEBUG, StringConcatenate( sLogPrefix, "Daily tick. Now go do some logic with ", DoubleToStr( Bid, 5 ), " ..." ), kFunctionLoggingLevel );
   return( isDailyTick );
}



//+------------------------------------------------------------------+
//|                                            PHStickyTimepiece.mqh |
//|                                                      HearMonster |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "HearMonster"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
#include <PHLogger.mqh>


class PHStickyTimepiece  {
      private:
               datetime _tLastM1TimeframeSeen; 
               datetime _tLastH1TimeframeSeen; 
               datetime _tLastD1TimeframeSeen; 
               datetime _tLastW1TimeframeSeen; 

      public:
                      PHStickyTimepiece();
                      ~PHStickyTimepiece();
               bool   isANewMinutelyTick( string sSymbol );
               bool   isANewHourlyTick(   string sSymbol );
               bool   isANewDaylyTick(    string sSymbol );
               bool   isANewWeeklyTick(   string sSymbol );
  };
//+------------------------------------------------------------------+
//|   Constructor
//+------------------------------------------------------------------+
PHStickyTimepiece::PHStickyTimepiece() {

   //myLogger.logDEBUG( "PHStickyTimepiece::Constructor" );
   _tLastM1TimeframeSeen = -1; 
   _tLastH1TimeframeSeen = -1; 
   _tLastD1TimeframeSeen = -1; 
   _tLastW1TimeframeSeen = -1; 


}
  
  
//+------------------------------------------------------------------+
//|   Destructor
//+------------------------------------------------------------------+
PHStickyTimepiece::~PHStickyTimepiece()
  {
  }
//+------------------------------------------------------------------+

// When should these return true?
//    - The start of EA will *probably* be mid-way through a bar, should that should return false (should wait until the next bar)
//    - A change of timeframe should not be treated as the start a new bar. So any new ticks after a change of timeframe, should remain false...until a real new bar appears
//    

//+------------------------------------------------------------------+
//|   Minutely Tick
//+------------------------------------------------------------------+
bool PHStickyTimepiece::isANewMinutelyTick( string sSymbol ) {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   if ( sSymbol == "" ) sSymbol = Symbol();
   bool isNewMinutelyTick = false;   //you can assume that the first time around this'll be false
   datetime tTimeframeForNewM1Tick = iTime( sSymbol, PERIOD_M1, 0 );   //the *minute* of the tick
      // there appears to be a bug, the first time this gets called it produces an erroneous time! (wrong hour, wrong minute)

   myLogger.logDEBUG( "_tLastM1TimeframeSeen: " + string( _tLastM1TimeframeSeen ) + "; tTimeframeForNewM1Tick: " + string( tTimeframeForNewM1Tick ) );


   if ( _tLastM1TimeframeSeen == -1 ) {
      // Very, very first time.
      myLogger.logDEBUG( "First time testing for a new One-Minutely tick." );
      isNewMinutelyTick = false;

      //workaround for iTime() bug mentioned above - find the Date+Hour/Minute another way
      myLogger.logDEBUG( "woraround: " + TimeToStr( TimeCurrent(), TIME_DATE|TIME_MINUTES) );
      tTimeframeForNewM1Tick = StringToTime(TimeToStr( TimeCurrent(), TIME_DATE|TIME_MINUTES) );
      myLogger.logDEBUG( "REVISED  tTimeframeForNewM1Tick: " + string( tTimeframeForNewM1Tick ) );

//Alternative method for deriving the minute (ie DIV and/or MOD)???   barOpenTime [i] = Tick.Time - Tick.Time % (timeframes[i]*MINUTES

   } else {

      // Not the very first time. Let's compare the saved timestamp with the current one
      if ( _tLastM1TimeframeSeen != tTimeframeForNewM1Tick)  {
         isNewMinutelyTick = true;
         myLogger.logDEBUG( "New One Minutely tick detected." );
      } else {
         isNewMinutelyTick = false;
         myLogger.logDEBUG( "This is not a New One Minutely tick." );
      } //endif

   } //endif
   
   
   //Either way, always do this...
   //Remember this Minutely-timeframe (not the precise tick time, but the *minute* in which it occured) for next time
   _tLastM1TimeframeSeen = tTimeframeForNewM1Tick;

   return( isNewMinutelyTick );
}





//+------------------------------------------------------------------+
//|   Hourly Tick
//+------------------------------------------------------------------+
bool PHStickyTimepiece::isANewHourlyTick( string sSymbol ) {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   if ( sSymbol == "" ) sSymbol = Symbol();
   bool isNewHourlyTick;
   datetime tTimeframeForNewH1Tick = iTime( sSymbol, PERIOD_H1, 0 );   //the *Hour* of the tick
      // there appears to be a bug, the first time this gets called it produces an erroneous time! (wrong hour, wrong Hour)

   myLogger.logDEBUG( "_tLastH1TimeframeSeen: " + string( _tLastH1TimeframeSeen ) + "; tTimeframeForNewH1Tick: " + string( tTimeframeForNewH1Tick ) );


   if ( _tLastH1TimeframeSeen == -1 ) {
      // Very, very first time.
      myLogger.logDEBUG( "First time testing for a new One-Hourly tick." );
      isNewHourlyTick = false;

   } else {

      // Not the very first time. Let's compare the saved timestamp with the current one
      if ( _tLastH1TimeframeSeen != tTimeframeForNewH1Tick)  {
         isNewHourlyTick = true;
         myLogger.logDEBUG( "New One Hourly tick detected." );
      } else {
         isNewHourlyTick = false;
         myLogger.logDEBUG( "This is not a New One Hourly tick." );
      } //endif

   } //endif
   
   
   //Either way, always do this...
   //Remember this Hourly-timeframe (not the tick, but the *Hour* in which it occured) for next time
   _tLastH1TimeframeSeen = tTimeframeForNewH1Tick;

   return( isNewHourlyTick );
}






//+------------------------------------------------------------------+
//|   Dayly Tick  (spelt wrong, I know - but keeping naming consistent!)
//+------------------------------------------------------------------+
bool PHStickyTimepiece::isANewDaylyTick( string sSymbol ) {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   if ( sSymbol == "" ) sSymbol = Symbol();
   bool isNewDaylyTick;
   datetime tTimeframeForNewD1Tick = iTime( sSymbol, PERIOD_D1, 0 );   //the *Day* of the tick
      // there appears to be a bug, the first time this gets called it produces an erroneous time! (wrong Day, wrong Day)

   myLogger.logDEBUG( "_tLastD1TimeframeSeen: " + string( _tLastD1TimeframeSeen ) + "; tTimeframeForNewD1Tick: " + string( tTimeframeForNewD1Tick ) );


   if ( _tLastD1TimeframeSeen == -1 ) {
      // Very, very first time.
      myLogger.logDEBUG( "First time testing for a new One-Dayly tick." );
      isNewDaylyTick = false;

   } else {

      // Not the very first time. Let's compare the saved timestamp with the current one
      if ( _tLastD1TimeframeSeen != tTimeframeForNewD1Tick)  {
         isNewDaylyTick = true;
         myLogger.logDEBUG( "New One Dayly tick detected." );
      } else {
         isNewDaylyTick = false;
         myLogger.logDEBUG( "This is not a New One Dayly tick." );
      } //endif

   } //endif
   
   
   //Either way, always do this...
   //Remember this Dayly-timeframe (not the tick, but the *Day* in which it occured) for next time
   _tLastD1TimeframeSeen = tTimeframeForNewD1Tick;

   return( isNewDaylyTick );
}




//+------------------------------------------------------------------+
//|   Weekly Tick
//+------------------------------------------------------------------+
bool PHStickyTimepiece::isANewWeeklyTick( string sSymbol ) {
   LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   if ( sSymbol == "" ) sSymbol = Symbol();
   bool isNewWeeklyTick;
   datetime tTimeframeForNewW1Tick = iTime( sSymbol, PERIOD_W1, 0 );   //the *Week* of the tick
      // there appears to be a bug, the first time this gets called it produces an erroneous time! (wrong Week, wrong Week)

   myLogger.logDEBUG( "_tLastW1TimeframeSeen: " + string( _tLastW1TimeframeSeen ) + "; tTimeframeForNewW1Tick: " + string( tTimeframeForNewW1Tick ) );


   if ( _tLastW1TimeframeSeen == -1 ) {
      // Very, very first time.
      myLogger.logDEBUG( "First time testing for a new One-Weekly tick." );
      isNewWeeklyTick = false;

   } else {

      // Not the very first time. Let's compare the saved timestamp with the current one
      if ( _tLastW1TimeframeSeen != tTimeframeForNewW1Tick)  {
         isNewWeeklyTick = true;
         myLogger.logDEBUG( "New One Weekly tick detected." );
      } else {
         isNewWeeklyTick = false;
         myLogger.logDEBUG( "This is not a New One Weekly tick." );
      } //endif

   } //endif
   
   
   //Either way, always do this...
   //Remember this Weekly-timeframe (not the tick, but the *Week* in which it occured) for next time
   _tLastW1TimeframeSeen = tTimeframeForNewW1Tick;

   return( isNewWeeklyTick );
}

//|------------------------------------------------------------------+
//|                                                     PHLogger.mq4 |
//|                                    Copyright © 2020, HearMonster |
//|                                         mailto:hearmonster@pm.me |
//|------------------------------------------------------------------+
#property copyright "Copyright © 2020, HearMonster"
#property link      "mailto:hearmonster@pm.me"
#property strict

#define LLP( _threshold) string sLLP = StringSubstr(__FILE__,0,StringLen(__FILE__)-4) + "::" + __FUNCTION__ + "::"; eLogLevels eLT = _threshold;  // Log Line Prefix & Log Threshold
#define logALL( _text )   logWrite( LOG_ALL, eLT, sLLP, _text );
#define logFATAL( _text ) logWrite( LOG_FATAL, eLT, sLLP, _text );
#define logERROR( _text ) logWrite( LOG_ERROR, eLT, sLLP, _text );
#define logWARN( _text ) logWrite( LOG_WARN, eLT, sLLP, _text );
#define logINFO( _text )  logWrite( LOG_INFO,  eLT, sLLP, _text );
#define logDEBUG( _text ) logWrite( LOG_DEBUG, eLT, sLLP, _text );

//Used by Prepreocessor to detect wether this include file has already been included
#define _logger 1

//+------------------------------------------------------------------+
//|  HOW DO I USE THIS?
//|
//|  Place these two lines towards the top of your code: 
//|    (the #include belongs at the head of the code, and the other line is a
//|     declaration of a global variable - so that belongs at the top anyway)
//|
/*

   #include <PHLogger.mqh>

*/
//|
//|  Note that the included header file actually instantiates an instance of my PHLogger class for you, named "myLogger"
//|  Then whenever you want to write to the log, use something like:
//|
/*

   myLogger.logINFO( "Bars: " + string(Bars) );

*/
//|   Aside: You won't actually find any methods named, LOGxxxx, they're actually Macros that conveniently 
//|      set a whole bunch of parameters for you, leaving you just to supply *only* the message text!
//|
//|  <RECOMMENDED>:
//|  Place a line similar to this at the start of *every)* method. It will set
//|   a) the Log Line Prefix (i.e. the file and function name) automatically for you
//|   b) the threshold for this function (any messages equal to, or more severe than this will appear in the log)
//|
/*

   LLP( LOG_INFO ) //Log File Prefix

*/
//|
//|  There's no need to clean it up in the DeInit() - it'll clean itself up
//|
//|  <RECOMMENDED> For anything other than a short-running script, set up a timer to flush the log
//|                (A short-running script will flush it's log file at completion automatically)
//|
/*

  int OnInit() {
      //--- create timer (used for flushing the log file)
      EventSetTimer(2);
      ...

   void OnDeinit(const int reason)
     {
      //--- destroy timer
      EventKillTimer();
      ...

   void OnTimer()
     {
      myLogger.fileFlush();
      ...

*/
//|
//|




//+------------------------------------------------------------------+
//|  WHERE DO THE (LOG) FILES GET WRITTEN?
//|
//| The Terminal is installed into:
//| C:\Users\i817399\AppData\Roaming\MetaQuotes\Terminal\F2262CFAFF47C27887389DAB2852351A
//| (I'll refer to this as <TERMINAL_HOME> below)
//|
//| WHICH DIRETCTORY?
//| The *Directory* in which the file will be created:
//|    When run as a *Script*:         <TERMINAL_HOME>\MQL4\Files
//|    When run as an *Expert*:        <TERMINAL_HOME>\MQL4\Files
//|    But when run under the Tester:  <TERMINAL_HOME>\Tester\files\"
//|
//| UNDER WHAT FILENAME?
//| The file name will be:
//|  <Expert Name>(<Symbol>~<Period>).log   e.g. "PHTickTest(EURUSD~M1).log"
//|
//|   When executed under the MetaEditor, check Tools >> Options >> Debug [tab] for the <Symbol> and <Period>
//|   When executed under the Terminal TESTER, see the <Symbol> and <Period> fields
//|
//| FYI Remember that you *also* have
//|   a) Script/Expert Log files (the result of 'Print' functions) under "...\MetaTrader 4\experts\logs\"
//|   b) Tester Log files (loading of ex4 scripts + the result of trade opens & closes) under "...\MetaTrader 4\experts\logs\"
//|   c) MT4 System Log files (the result of trades) under "...\MetaTrader 4\logs\"
//|
//| "Print" commands get written to <TERMINAL_HOME>\MQL4\Logs\<YYYYMMDD>.log"
//|
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| WHEN DO THE LINES GET APPENDED? (When will my lines appear in the file?)
//|
//| Flushing appears to be a definite issue with MT4!  :o(
//|
//| So I've allowed you to specify a counter - which flushes the log file exery 
//|   'x' rows appended
//|
//| You can also set up the Timer (in your calling script's INIT method) to 
//|   explicitly call my Flush() method every 'x' seconds
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| HOW DO THE LINES GET APPENDED? (i.e. Under what conditions?)
//|
//| Will only write if the MessageLevel is *more serious* i.e a lower value
//|  than the calling function's Threshold
//|
//| Note that the LOG_OFF will almost *completely disable* the logs!
//|  - Absolutely *no logs* will be written irrespective of the seriousness
//|  - Even attempting to write a LOG_FATAL will *not* get written!
//|  - However, sending a log with a MessageLevel of LOG_OFF will always
//|    appear in the logs
//+------------------------------------------------------------------+

enum eLogLevels  // enumeration of named constants 
  { LOG_OFF   = 0,
    LOG_FATAL = 1,
    LOG_ERROR = 2,
    LOG_WARN = 3,
    LOG_INFO = 4,
    LOG_DEBUG = 5
  };




#include <PHFilePrinter.mqh>      //Base Class

class PHLogger : public PHFilePrinter {

   private:
      //<<<private attributes>>>
      int      _nLogFatalCount, _nLogErrorCount, _nLogWarnCount;    //End of trace Statistics (used by 'log()' and 'log_close()' functions)
      string   _sFilename;

   public:
      //<<<Constructors>>>
               PHLogger ();
               ~PHLogger() { filePrint( "Log file closing." ); }

      //<<<public methods>>>
      void     logPrintSummaryStats();
      void     logWrite( eLogLevels eMessageLevel, eLogLevels eLogThreshold, string sLogPrefix, string text  );
/*
These 'convenience' methods don't actually exist, but can be called like this because of the macros I've defined above
      void     logFATAL( string text  );
      void     logERROR( string text  );
      void     logINFO(  string text  );
      void     logWARN(  string text  );
      void     logDEBUG( string text  );
*/
      
}; // end class HEADER



//+------------------------------------------------------------------+
//|   Constructor
//+------------------------------------------------------------------+
void PHLogger::PHLogger() {
// We need:
//    1. A filename - auto constructed below [_sFilename]
//    2. (optional) A log level [nLogLevelParam]


   // Construct the log filename:  <ExpertName> || "(" || <Symbol Pair> || "~" || <Period> || ").log"
   string sWindowPeriod = StringSubstr( EnumToString( ChartPeriod( 0 ) ), 7 ); // ChartPeriod( 0 ) = Current chart. EnumToString() will return e.g. "PERIOD_D1" for DAILY
   string sCurrencyPair = ChartSymbol( 0 );  // ChartSymbol( 0 ) = Current chart. Returns string
   _sFilename = WindowExpertName() + "(" + sCurrencyPair + "~" + sWindowPeriod + ").log";

   //Unlike the Base Class, we can take the opportunity to open the file implicitly (because we've automatically constructed the filename), without the need for a 'logOpen' call
   fileOpen( _sFilename );

   //End of trace Statistics (used by 'log()' and 'log_close()' functions)
   _nLogFatalCount = 0;
   _nLogErrorCount = 0;
   _nLogWarnCount  = 0;    

}

//+------------------------------------------------------------------+
//|   Desstructor
//+------------------------------------------------------------------+
/*
void PHLogger::~PHLogger() {

      filePrint( "Log file closing." );
}
*/





//|------------------------------------------------------------------+
//|  Print Summary Stats
//|   Count of Fatals, Errors and Warnings
//|------------------------------------------------------------------+
void PHLogger::logPrintSummaryStats() {

   filePrint( "Final count of FATAL logs: " + string(_nLogFatalCount) );
   filePrint( "Final count of ERROR logs: " + string(_nLogErrorCount) );
   filePrint( "Final count of WARN logs:  " + string(_nLogWarnCount) );
}
     


//+------------------------------------------------------------------+
// Write a line of text to the message file...
//
// ...assuming it's severity is more serious than the calling 
// function's local level
// (actually, we look for a *lower than or equal to* threshold)
//
//+------------------------------------------------------------------+
void PHLogger::logWrite( eLogLevels eMessageLevel, eLogLevels eLogThreshold, string sLogPrefix, string text  ) {

	//If invalid file handle then Abort!
	if ( iFileHandle == INVALID_HANDLE )	{
		Print( "Log write error! Text: ", text );
      //'Print' - see my note above about where "Print" commands get written
		return;
	}

   //Increment Statistics - onlyu applicable for FATAL, ERROR and WARN messages
	switch ( eMessageLevel )
	{
		case LOG_OFF:   break;
		case LOG_FATAL: _nLogFatalCount++; break;
		case LOG_ERROR: _nLogErrorCount++; break;
		case LOG_WARN:  _nLogWarnCount++; break;
		case LOG_INFO:  break;
		case LOG_DEBUG: break;
		default:		    break;
	} //end switch
   
   //Only write if the MessageLevel is more serious than the two Thresholds (the Global Threshold, OR the calling function's Threshold)
   //if ( (nMessageLevel <= nGlobalLogLevelThreshold) || (nMessageLevel <= nFunctio_nLogLevelThreshold) ) {
   //Only write if the MessageLevel is more serious than the calling function's Threshold
   if (eMessageLevel <= eLogThreshold ) {
   
      //Prefix the line with the Log Level, any FILE and/or FUNCTION prefix (specified).  The FilePrinter prefixes all of it with the datetime.
      sLogPrefix =  StringSubstr( EnumToString( eMessageLevel ), 4 ) + "::" + sLogPrefix;
      filePrint( sLogPrefix + text );
   }
      
}


//<<<Global Variables>>>
//Instanciate an instance of my PHLogger class for your convenience, named "myLogger"
PHLogger myLogger();


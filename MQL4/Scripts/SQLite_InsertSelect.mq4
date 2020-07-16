//+------------------------------------------------------------------+
//|                                            TestSQLite3Select.mq4 |
//|                                          Copyright 2018, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <SQLite3/Statement.mqh>

#include <PHLogger2020.mqh>      //LOGGER - include log file code
//<<<Global Variables>>>         //LOGGER
PHLogger2020 myTraceLogger;      //LOGGER

//+------------------------------------------------------------------+
//|  Notes for execution:                                            |
//|   1. SCRIPT *MUST* BE RUN WITH "Allow DLL Imports" *ENABLED*     |
//|   2. Assumes that the datbase files already exists               |
//|      (otherwise will error)                                      |
//|                                                                  |
//|  General life cycle:                                             |
//|    [Category] [SQLite3 C API]           [mql-sqlite3 equivalent] |
//|   opening:     sqlite3_open_v2   >>>     SQLite3::SQLite3        |
//|   errors:      sqlite3_errcode   >>>     SQLite3::getErrorCode   |
//|     "          sqlite3_errmsg    >>>     SQLite3::getErrorMsg    |
//|     "          sqlite3_errstr    >>>     SQLite3::errorCode2Msg  |
//|   closing:     sqlite3_close_v2  >>>     SQLite3::~SQLite3       |
//|                                                                  |
//|                                                                  |
//|   life-cycle of a prepared statement object:                     |
//|     1. Create the prepared statement object using sqlite3_prepare_v2() >>>   Statement::Statement  (Statement Class' Constructor)
//|     2. Bind values to parameters using the sqlite3_bind_*() interfaces >>>   Statement::bind
//|     3. Run the SQL by calling sqlite3_step() one or more times         >>>   Statement::step
//|     4. Reset the prepared statement using sqlite3_reset()              >>>   Statement::reset
//|          then go back to step 2. Do this zero or more times.
//|                      TODO Further investigate: sqlite3_clear_bindings  >>>   Statement::clearBindings
//|     5. Destroy the object using sqlite3_finalize()                     >>>   SQLite3::~SQLite3
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   //Open Log File (Overwrite mode)                                  //LOGGING
   string sLogPrefix = __FILE__ + "::" + __FUNCTION__ + "::";        //LOGGING
   int kFunctionLoggingLevel = LOG_DEBUG;                            //LOGGING
  
   myTraceLogger.logOpen( __FILE__, true );                          //LOGGING
   myTraceLogger.logPrint( sLogPrefix + "Starting Logging..." );     //LOGGING


//--- optional but recommended
   SQLite3::initialize();

//--- open database
#ifdef __MQL5__
   string filesPath = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files";
#else
   string filesPath = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";
#endif
   string dbPath= filesPath + "\\test.db";
   myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "dbPath: ", dbPath) );      
   //Print(dbPath);

   // Instantiate an instance 'db' of the 'SQLite3' Class
   SQLite3 db( dbPath,SQLITE_OPEN_READWRITE ); //The database is opened for reading and writing if possible, or reading only if the file is write protected by the operating system. In either case the database must already exist, otherwise an error is returned.
   if( !db.isValid() ) {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "SQLLite3 database instance 'db' invalid after open: ", db.getErrorMsg() ) );
      myTraceLogger.logFlush();
      return;
   } else {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "SQLLite3 database instance 'db' opened. " ) );
      //SQLite3::isAutoCommit
      if ( db.isAutoCommit() ) {
         myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "SQLLite3 database instance 'db' has AutoCommit set" ) );
      } else {
         myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "SQLLite3 database instance 'db' has AutoCommit UNset" ) );
      }
            
   } //endif

   string sql;

//Complete definition of Statement method:      Statement::Statement(const SQLite3 &conn,string sql)
   

   // <<<INSERT VALUES>>>
   string insertSql="INSERT INTO buy_orders VALUES( ?, ? );";
   MathSrand(GetTickCount());    // Initialize the generator of random numbers 
   
   Statement myPreparedSqlStatmentInstance_Insert( db, insertSql );     //Constructor for Statement Class
   if( !myPreparedSqlStatmentInstance_Insert.isValid() ) {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "db Error Message (after Prepare INSERT): ", db.getErrorMsg() ) );      
      //Print(db.getErrorMsg());
      return;
   } else {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "Success (after INSERT Prepare Statement). " ) );      

      //FYI: Full Signature for the Statement class' "bind" method>   int Statement::bind(int i,double value)
      
      int randomInt;
      string randomString;
      int ret1a, ret1b, ret2; //return codes
      
      //1st INSERT
      randomInt = MathRand();   //returns a "random" integer value within the range of 0 to 32767
      ret1a = myPreparedSqlStatmentInstance_Insert.bind( 1 , randomInt );
      randomString = string( GetTickCount() );   //returns an integer of the time with milliseconds - why not?
      ret1b = myPreparedSqlStatmentInstance_Insert.bind( 2 , randomString );
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "1st INSERT: random values submitted (BIND INSERT SQL): ", randomInt, " , ", randomString ) );      
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "1st INSERT: result of ret1a & ret1b (BIND INSERT SQL): ", ret1a, " , ", ret1b ) );      

      ret2 = myPreparedSqlStatmentInstance_Insert.step();
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "1st INSERT: result of ret2 (RUN ['step'] INSERT SQL): ", ret2 ) );      

      //2nd INSERT
      int resetPrepStmt = myPreparedSqlStatmentInstance_Insert.reset();
      int ClearBindngsPrepStmt = myPreparedSqlStatmentInstance_Insert.clearBindings();
      
      randomInt = MathRand();   //returns a "random" integer value within the range of 0 to 32767
      ret1a = myPreparedSqlStatmentInstance_Insert.bind( 1 , randomInt );
      randomString = string( GetTickCount() );   //returns an integer of the time with milliseconds - why not?
      ret1b = myPreparedSqlStatmentInstance_Insert.bind( 2 , randomString );
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "2nd INSERT: random values submitted (BIND INSERT SQL): ", randomInt, " , ", randomString ) );      
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "2nd INSERT: result of ret1a & ret1b (BIND INSERT SQL): ", ret1a, " , ", ret1b ) );      

      ret2 = myPreparedSqlStatmentInstance_Insert.step();
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "2nd INSERT: result of ret2 (RUN ['step'] INSERT SQL): ", ret2 ) );      
   } //endif




/*old INSERT (working)
   //Statement::bind(int i,int value);


   sql="INSERT INTO buy_orders VALUES( ?, ? );";
   Statement sqlStmt1( db,sql );
   if( !sqlStmt1.isValid() ) {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "db Error Message (after INSERT): ", db.getErrorMsg() ) );      
      //Print(db.getErrorMsg());
      return;
   } else
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "Success (after INSERT Statement). " ) );      
*/   


   sql="commit;";
   Statement sqlStmt1a( db, sql );
   if( !sqlStmt1a.isValid() ) {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "db Error Message (after COMMIT): ", db.getErrorMsg() ) );      
      //Print(db.getErrorMsg());
      return;
   } else
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "Success (after COMMIT Statement). " ) );      


   sql="select a, b from buy_orders;";
   Statement myPreparedSqlStatmentInstance_Select( db, sql );       //Constructor for Statement Class
   if( !myPreparedSqlStatmentInstance_Select.isValid() ) {
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "db Error Message (after SELECT): ", db.getErrorMsg() ) );      
      //Print(db.getErrorMsg());
      return;
   } else
      myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "Success (after SELECT Statement). " ) );      


   int r = myPreparedSqlStatmentInstance_Select.step();
   myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "r:", r ) );   
   do {
      if(r==SQLITE_ROW) {
         myTraceLogger.logPrint( StringConcatenate( sLogPrefix, ">>> New SQLITE_ROW !" ) );      
         //Print(">>> New row!");

         //Iterate through returned dataset columns
         int colCount = myPreparedSqlStatmentInstance_Select.getColumnCount();
         for( int colNum = 0; colNum < colCount; colNum++ ) {
         
            //I need to handle the columns with regard to their data type
            if( colNum == 0 ) {
               int intValue;
               myPreparedSqlStatmentInstance_Select.getColumn( colNum, intValue );
               //Print(sqlStmt2.getColumnName(i),": ",value);
               myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "(when colNum=0) " + myPreparedSqlStatmentInstance_Select.getColumnName( colNum ),": ", intValue ) );      
            }  //endif
            else if( colNum == 1 ) {
               string strValue;
               myPreparedSqlStatmentInstance_Select.getColumn( colNum, strValue );
               //Print(s.getColumnName(i),": ",value);
               myTraceLogger.logPrint( StringConcatenate( sLogPrefix, "(when colNum=1) " + myPreparedSqlStatmentInstance_Select.getColumnName( colNum ),": ", strValue ) );      
            }  //endif
         }  //end for
       } else {
           myTraceLogger.logPrint( StringConcatenate( sLogPrefix, ">>> No more rows!" ) );      
           break;
       }

      r = myPreparedSqlStatmentInstance_Select.step();
   } //end do
   while( r != SQLITE_DONE );

//--- optional but recommended
   SQLite3::shutdown();
  }
//+------------------------------------------------------------------+


void OnDeinit(const int reason)
  {
   //Close Log File
   myTraceLogger.logClose( false );
  }

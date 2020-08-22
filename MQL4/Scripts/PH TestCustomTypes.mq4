//+------------------------------------------------------------------+
//|                                           PH TestCustomTypes.mq4 |
//|                                                      HearMonster |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "HearMonster"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#ifndef _PHCustomTypes
   #include <PH Custom Types.mqh>
#endif 

#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

   PHDecimal oDec_BAD();
   int iPrecision = 2;
   int iTest = 0;
   double dInitialUnits = 12.11;
   double dAddUnits_a = 3;
   double dAddUnits_b = 3;
   double dAddUnits_c = 3;
   double dSubUnits = 3;
   double dMultUnits = 3;
   double dDivUnits = 3;
   
   //PHDecimal num_1;
   double dNum_Value;
   bool   bNum_res;
   
   PH_FX_PAIRS eSymbol;


//<<< PHDecimal >>>

      iTest = 1;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Default Constructor { no params } - test .toNormalizedDouble() on an uninitialized object", iTest ) );
      PHDecimal num_BAD(  );
      double dNumBAD_Value = num_BAD.toNormalizedDouble();
      myLogger.logINFO(  num_BAD.isValueReadable() ? StringFormat( "dNumBAD_Value : %.8g", dNumBAD_Value ) : "Object is BAD" );
      

      iTest = 2;
      dInitialUnits = 12.11;
      iPrecision = 2;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor { value = %.8g, precision = %.8g }>", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_1( dInitialUnits, iPrecision );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD : %.8g  << Should be: %.8g", dNum_Value, dInitialUnits )  : "Object is BAD" );

      iTest = 3;
      dInitialUnits = 12.119;
      iPrecision = 2;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor { value = %.8g, precision = %.8g }>", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_2( dInitialUnits, iPrecision );
      dNum_Value = num_2.toNormalizedDouble();
      myLogger.logINFO( num_2.isValueReadable() ? StringFormat( "Object is GOOD : %.8g << Should be: 12.12 i.e. rounded up to 2dp", dNum_Value )  : "Object is BAD" );

      iTest = 4;
      dInitialUnits = 12.34567;
      iPrecision = 5;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor { value = %.8g, precision = %.8g }>", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_3( dInitialUnits, iPrecision );
      dNum_Value = num_3.toNormalizedDouble();
      myLogger.logINFO( StringFormat( "dNum_Value : %.8g  << Should be: 12.34567", dNum_Value ) );

      iTest = 5;
      dInitialUnits = 1;
      iPrecision = 15;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor (PRECISION IS OUT OF BOUNDS/TOO HIGH)  value = %.8g, precision = %.8g ", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_4( dInitialUnits, iPrecision );  //Too high precision
      dNum_Value = num_4.toNormalizedDouble();
      myLogger.logINFO( num_4.isValueReadable() ? StringFormat( "Object is GOOD : %.8g", dNum_Value ) : "Object is BAD"  );

      iTest = 6;
      dInitialUnits = 1;
      iPrecision = -1;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor (PRECISION IS OUT OF BOUNDS/NEGATIVE/TOO LOW)  value = %.8g, precision = %.8g ", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_5( dInitialUnits, iPrecision );  //Too low precision
      dNum_Value = num_5.toNormalizedDouble();
      myLogger.logINFO( num_5.isValueReadable() ? StringFormat( "Object is GOOD : %.8g", dNum_Value ) : "Object is BAD"  );

      iTest = 7;
      dInitialUnits = 12.9;
      iPrecision = 0;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <Constructor (INT)  value = %.8g, precision = %.8g ", iTest, dInitialUnits, iPrecision ) );
      PHDecimal num_6( dInitialUnits, iPrecision );  //effectively an INT
      dNum_Value = num_6.toNormalizedDouble();
      myLogger.logINFO( num_6.isValueReadable() ? StringFormat( "Object is GOOD : %.8g", dNum_Value ) : "Object is BAD"  );


//setValue() + Addition (pos number) @2dp
//reusing Object #1
      iTest = 8;
      dInitialUnits = 12.11;
      iPrecision = 2;
      dAddUnits_a = 0.238;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <setValue { value = %.8g, precision = %.8g (INT) }>, then ADD %.8g...>", iTest, dInitialUnits, iPrecision, dAddUnits_a  ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.add( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after adding %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );
      
      iTest = 9;
      dAddUnits_a = 0.059;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal ADD %.8g...>", iTest, dAddUnits_a  ) );
      num_1.add( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after adding %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );

//setValue() + Addition (neg number) @5dp
      iTest = 10;
      iPrecision = 5;
      dAddUnits_a = -0.059;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <setValue { value = %.8g, precision = %.8g }>, then ADD %.8g...>", iTest, dInitialUnits, iPrecision, dAddUnits_a  ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.add( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after adding %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );


//setValue() + Subtraction (pos number) @2dp
      iTest = 11;
      dInitialUnits = 12.11;
      iPrecision = 2;
      dAddUnits_a = 0.238;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <setValue { value = %.8g, precision = %.8g }>, then SUBTRACT %.8g ...>", iTest, dInitialUnits, iPrecision, dAddUnits_a  ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.subtract( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after subtracting %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );

      iTest = 12;
      dAddUnits_a = 0.059;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal SUBTRACT %.8g ...>", iTest, dAddUnits_a  ) );
      num_1.subtract( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after subtracting %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );

//setValue() + Subtraction (neg number) @5dp
      iTest = 13;
      iPrecision = 5;
      dAddUnits_a = -0.059;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal <setValue { value = %.8g, precision = %.8g (INT) }>, then SUBTRACT %.8g...>", iTest, dInitialUnits, iPrecision, dAddUnits_a  ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.subtract( dAddUnits_a );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after subtracting %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );


// Addition to an uninitialized object
//reusing Object BAD
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal ADD %.8g to an uninitialized object", iTest, dAddUnits_a  ) );
      num_BAD.add( dAddUnits_a );
      dNum_Value = num_BAD.toNormalizedDouble();
      myLogger.logINFO( num_BAD.isValueReadable() ? StringFormat( "Object is GOOD after adding %.8g: %.8g", dAddUnits_a, dNum_Value ) : "Object is BAD"  );


   iTest = 14;
      double d1 = 0.1;
      double d2 = 0.2;
      double d3 = 0.3;
      myLogger.logINFO(  StringFormat( "\r\n\nTest %i: BAD DOUBLES: math logic: %.8g + %.8g - %.8g   Result: %.8g", iTest, d1, d2, d3, (d1 + d2 - d3) ) );
      myLogger.logINFO(  StringConcatenate( StringFormat( "\r\n\nTest %i: BAD DOUBLES: bool logic: (%.8g + %.8g) == %.8g   Result: ", iTest, d1, d2, d3 ) , ( (d1+d2) == d3 ) ) );

   //Comparison
   iTest = 15;
      dInitialUnits = 0.1;
      iPrecision = 1;
      dAddUnits_a = 0.2;
      dAddUnits_b = 0.3;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i-a: PHDecimal COMPARE (( %.8g + %.8g ) == %.8g )", iTest, dInitialUnits, dAddUnits_a, dAddUnits_b ) );
      
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.add( dAddUnits_a );
      bNum_res = num_1.compare( dAddUnits_b );
      myLogger.logINFO(  StringConcatenate( StringFormat( "COMPARISON: compare [%.8g + %.8g] == %.8g Result: ", dInitialUnits, dAddUnits_a, dAddUnits_b), bNum_res ) );
      
      num_1.subtract( dAddUnits_b );
      myLogger.logINFO(  StringFormat( "\r\n\nTest %i-b: PHDecimal (should get to zero): [%.8g + %.8g - %.8g] Result1: %s", iTest, dInitialUnits, dAddUnits_a, dAddUnits_b, num_1.toString() ) );
     
     
   //Multiplication
   iTest = 16;
      dInitialUnits = 15;
      iPrecision = 5;
      dAddUnits_a = 20;
      dAddUnits_b = -0.586;

      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal (MULTIPLY) - Initial: { value = %.8g, precision = %.8g } then MULTIPLY by %.8g, MULTIPLY by %.8g ...>", iTest, dInitialUnits, iPrecision, dAddUnits_a, dAddUnits_b ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.multiply( dAddUnits_a );
      num_1.multiply( dAddUnits_b );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after multiplication : %.8g", dNum_Value ) : "Object is BAD"  );
  

   //Division
   iTest = 17;
      dInitialUnits = 25;
      iPrecision = 5;
      dAddUnits_a = 15;
      dAddUnits_b = -0.586;

      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal (DIVIDE) - Initial: { value = %.8g, precision = %.8g } then DIVIDE by %.8g, DIVIDE by %.8g ...>", iTest, dInitialUnits, iPrecision, dAddUnits_a, dAddUnits_b ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.divide( dAddUnits_a );
      num_1.divide( dAddUnits_b );
      dNum_Value = num_1.toNormalizedDouble();
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after division : %.8g", dNum_Value ) : "Object is BAD"  );




// OVERFLOW:  Max Long value is 9,223,372,036,854,775,807
// This gets me to 9e+14 (900000000000000.00) - I can't seem to get much higher (but that is with 2DPs)
   iTest = 16;
      dInitialUnits = 60000000;
      iPrecision = 2;
      dAddUnits_a = 10000000;

      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHDecimal (MULTIPLY) - Initial: { value = %.8g, precision = %.8g } then MULTIPLY by %.8g, MULTIPLY by %.8g ...>", iTest, dInitialUnits, iPrecision, dAddUnits_a, dAddUnits_b ) );
      num_1.setValue( dInitialUnits, iPrecision );
      num_1.multiply( dAddUnits_a );
      //num_1.add( dAddUnits_c );
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after multiplication of (%.8g x %.8g) = %s", dInitialUnits, dAddUnits_a, num_1.toString() ) : "Object is BAD"  );

      dAddUnits_b = 10;
      num_1.multiply( dAddUnits_b );
      myLogger.logINFO( num_1.isValueReadable() ? StringFormat( "Object is GOOD after multiplication : (%.8g x %.8g x %.8g) = %s", dInitialUnits, dAddUnits_a, dAddUnits_b, num_1.toString() ) : "Object is BAD"  );



   //Less Than or Equal To
   iTest = 17;    // 25 <= 55 i.e. TRUE
      //Object #1
      dInitialUnits = 25;
      iPrecision = 5;
      num_1.setValue( dInitialUnits, iPrecision );
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: \t\t\t\t\t\tPHDecimal (lte) - Initial Object #1: { value = %.8g, precision = %i }", iTest, dInitialUnits, iPrecision ) );

      //Object #2
      dAddUnits_a = 55;
      num_2.setValue( dAddUnits_a, iPrecision );  //deliberately using same precision
      myLogger.logINFO( StringFormat( "PHDecimal (lte) - Initial Object #2: { value = %.8g, precision = %i }", dAddUnits_a, iPrecision ) );

      bNum_res = num_1.lessThanOrEqualTo( num_2 );
      myLogger.logINFO( num_1.isValueReadable() ? StringConcatenate( StringFormat( "Object is GOOD after lte comparison : %s <= %s >>> Result: ", num_1.toString(), num_2.toString() ), bNum_res ) : "Object is BAD"  );


   iTest = 18;    // 50 <= 50 i.e. TRUE
      //Object #1
      dInitialUnits = 50;
      iPrecision = 5;
      num_1.setValue( dInitialUnits, iPrecision );
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: \t\t\t\t\t\tPHDecimal (lte) - Initial Object #1: { value = %.8g, precision = %i }", iTest, dInitialUnits, iPrecision ) );

      //Object #2
      dAddUnits_a = 50;
      num_2.setValue( dAddUnits_a, iPrecision );  //deliberately using same precision
      myLogger.logINFO( StringFormat( "PHDecimal (lte) - Initial Object #2: { value = %.8g, precision = %i }", dAddUnits_a, iPrecision ) );

      bNum_res = num_1.lessThanOrEqualTo( num_2 );
      myLogger.logINFO( num_1.isValueReadable() ? StringConcatenate( StringFormat( "Object is GOOD after lte comparison : %s <= %s >>> Result: ", num_1.toString(), num_2.toString() ), bNum_res ) : "Object is BAD"  );

   iTest = 19;    // 50 <= 45 i.e. FALSE
      //Object #1
      dInitialUnits = 50;
      iPrecision = 5;
      num_1.setValue( dInitialUnits, iPrecision );
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: \t\t\t\t\t\tPHDecimal (lte) - Initial Object #1: { value = %.8g, precision = %i }", iTest, dInitialUnits, iPrecision ) );

      //Object #2
      dAddUnits_a = 45;
      num_2.setValue( dAddUnits_a, iPrecision );  //deliberately using same precision
      myLogger.logINFO( StringFormat( "PHDecimal (lte) - Initial Object #2: { value = %.8g, precision = %i }", dAddUnits_a, iPrecision ) );

      bNum_res = num_1.lessThanOrEqualTo( num_2 );
      myLogger.logINFO( num_1.isValueReadable() ? StringConcatenate( StringFormat( "Object is GOOD after lte comparison : %s <= %s >>> Result: ", num_1.toString(), num_2.toString() ), bNum_res ) : "Object is BAD"  );





//<<< PHCurrDecimal >>>
/* Methods:
                           PHCurrDecimal::PHCurrDecimal() : _eSymbol( NULL), _sSymbol( NULL), _dCashRoundingStep( NULL), PHDecimal() { } ;   //Construct an UNINITIALIZED object
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const PH_FX_PAIRS eSymbol );  // Constructor #1 - The "real" Constructor
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol );  // Constructor #2 - Constructor for tesing Cash Rounding

         //Public Methods
         void              PHCurrDecimal::setValue( const double dInitialUnits, const PH_FX_PAIRS eSymbol );
         double            PHCurrDecimal::toNormalizedDouble() const;    // Override PHDecimal::toNormalizedDouble()
*/

   iTest = 20;
      //Object PHCurrDecimal #1
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHCurrDecimal <Default Constructor { no params } - test .toNormalizedDouble() on an uninitialized object", iTest ) );
      PHCurrDecimal numCurrDec_1(); // Dummy/uninitialized object
      myLogger.logINFO(  numCurrDec_1.isValueReadable() ? StringFormat( "numCurrDec_1.toSting() : %s", numCurrDec_1.toString() ) : "Object is BAD" );


   iTest = 21;
      //Object PHCurrDecimal #2
      dInitialUnits = 1.23456;
      eSymbol = EURUSD;
      myLogger.logINFO( StringFormat( "\r\n\nTest %i: PHCurrDecimal <Default Constructor { no params } - test .toNormalizedDouble() on an uninitialized object", iTest ) );
      PHCurrDecimal numCurrDec_2( dInitialUnits, eSymbol ); 
      myLogger.logINFO(  numCurrDec_2.isValueReadable() ? StringFormat( "numCurrDec_2.toSting() : %s", numCurrDec_2.toString() ) : "Object is BAD" );





/*

      double d_3b = 12.34;
      myLogger.logINFO( StringFormat( "\r\n\n<<<Next PHCurrDecimal>>>  value = %.8g, precision = 2, Step = 0.25 ...", d_3b ) );
      PHCurrDecimal num_3b( d_3b, 2, 0.01, 0.25 );
      double dNum_3b = num_3b.toNormalizedDouble();
      myLogger.logINFO( StringFormat( "12.34 @ Step: 0.25 : %.8g", dNum_3b )  );

      double d_3c = 12.49;
      myLogger.logINFO( StringFormat( "\r\n\n<<<Next PHCurrDecimal>>>  value = %.8g, precision = 2, Step = 0.25 ...", d_3c ) );
      PHCurrDecimal num_3c( d_3c, 2, 0.25 );
      double dNum_3c = num_3c.toNormalizedDouble();
      myLogger.logINFO( StringFormat( "12.34 @ Step: 0.25 : %.8g", dNum_3c )  );

/*      


     //PERCENT
      //PHPercent perc_BAD();  //UNABLE TO CALL ("wrong parameters count")

      myLogger.logINFO( "\r\n\n<<<Next Decimal>>>  value = 1, precision = 15 <PRECISION IS OUT OF BOUNDS/TOO HIGH>" );
      PHDecimal num_BAD3( 1, 15 );  //Too high precision
      num_BAD3.add( 3 );   //test to confirm that object is bad (will error)
      myLogger.logINFO( StringFormat( "(Numerical?) Result of .toNormalizedDouble of an UNSET value: %.8g",   num_BAD3.toNormalizedDouble() ) );
      string sBool = ( num_BAD3.toNormalizedDouble() == NULL ) ? "true" : "false";
      myLogger.logINFO( StringFormat( "Is the Boolean result of .toNormalizedDouble of an UNSET value: %s IS NULL?",   sBool ) );
      sBool = ( num_BAD3.toNormalizedDouble() == 0 ) ? "true" : "false";
      myLogger.logINFO( StringFormat( "Is the result of .toNormalizedDouble of an UNSET value EQUAL TO ZERO?: %s",   sBool ) );

      myLogger.logINFO( "\r\n\n<<<Next Percentage>>>  value = 26, precision = 3" );
      PHPercent perc_1( 26, 3 );  
      myLogger.logINFO( StringFormat( "Result of .toNormalizedDouble: %.8g",   perc_1.toNormalizedDouble() ) );
      myLogger.logINFO( StringFormat( "Percentage: getFigure : %.8g", perc_1.getFigure() ) );
      myLogger.logINFO( StringFormat( "Percentage: getPercent : %.8g", perc_1.getPercent() ) );
      myLogger.logINFO( StringFormat( "Percentage: toString(): %s", perc_1.toString() ) );
      
      myLogger.logINFO( "\r\n\n<<<Next Percentage>>>  value = 0.32, precision = 3 <Warn me to set the precentage between 0 and 100>" );
      PHPercent perc_mistake( 0.32, 2 );  //Warn me to set the precentage between 0 and 100
      myLogger.logINFO( StringFormat( "Result of .toNormalizedDouble: %.8g",   perc_mistake.toNormalizedDouble() ) );
      

      myLogger.logINFO( "\r\n\n<<<Next Percentage>>>  value = 100, precision = 2 <ERROR, Value is too high - Warn me that I'm overriding and setting to 100 instead" );
      PHPercent perc_BAD1( 999, 2 );  //Too high - override and set to 100 instead
      myLogger.logINFO( StringFormat( "Result of .toNormalizedDouble: %.8g",   perc_BAD1.toNormalizedDouble() ) );

      myLogger.logINFO( "\r\n\n<<<Next Percentage>>>  value = 0.32, precision = 3 <ERROR, Value is too low>" );
      PHPercent perc_BAD2( -5, 2 );   //Too low
      myLogger.logINFO( StringFormat( "Result of .toNormalizedDouble: %.8g",   perc_BAD2.toNormalizedDouble() ) );

*/      

/*
      double dLarge1 = 100000;
      double dSmall1 = 1.2;
      //double dResult1 = dLarge1 + dSmall1 - dLarge1;
      double dResult1 = (double) 100000 + (double) 1.2 - (double) 100000;
      myLogger.logINFO(  StringFormat( "\r\n\ndResult1: %.8g", dResult1 ) );

      double d_a = 1;
      double d_b = 0.0000000000000000000000001;
      double d_res = d_a + d_b;
      myLogger.logINFO(  StringFormat( "\r\n\nd_res: %.8g", d_res ) );

      double dMedium2 = 362.2;
      double dResult2 = dMedium2 - dMedium2;
      myLogger.logINFO(  StringFormat( "\r\n\ndResult2: %.8g", dResult2 ) );

      
      PHDecimal num_large( 100000 );
      num_large.add( 1.2 );
      num_large.subtract( 100000 );
      num_large.toNormalizedDouble();
      myLogger.logINFO(  "\r\n\nnum_large.toNormalizedDouble(): " + num_large.toString() );
*/      
      
   
      
/*
   //<<< Lots >>>
      PHLots lots_tooSmall( 0.0001, Symbol() );
      PHLots lots_tooBig( 999, Symbol() );
      PHLots lots_unNormalized( 0.056, Symbol() );
      PHLots lots_already_Normalised( 0.3, Symbol() );
   
      myLogger.logINFO(  "\r\n\nlots_tooSmall: "           + lots_tooSmall.toString() );
      myLogger.logINFO(  "lots_tooBig: "             + lots_tooBig.toString() );
      myLogger.logINFO(  "lots_unNormalized: "       + lots_unNormalized.toString() );
      myLogger.logINFO(  "lots_already_Normalised: " + lots_already_Normalised.toString() );
*/      
      
   //<<< Ticks >>>
/*
      PHTicks ticks_tooSmall( 0.000004 );
      PHTicks ticks_large( 999 );
      PHTicks ticks_unNormalized( 5.12345678, "GBPCHF" );   //Also a Cross Currency
      PHTicks ticks_already_Normalised( 1.23456 );
      PHTicks ticks_negative( -20, "USDCHF" );              //Also a non-USD Counter Currency
//      PHTicks ticks_copy1( ticks_already_Normalised );
//      PHTicks *ticks_copy2 = new PHTicks( ticks_already_Normalised );

      myLogger.logINFO(  "\r\n\nticks_tooSmall: "           + ticks_tooSmall.toString() );
      myLogger.logINFO(  "ticks_large: "              + ticks_large.toString() );
      myLogger.logINFO(  "ticks_unNormalized: "       + ticks_unNormalized.toString() );
      myLogger.logINFO(  "ticks_already_Normalised: " + ticks_already_Normalised.toString() );
      myLogger.logINFO(  "ticks_negative: "           + ticks_negative.toString() );

/*
   //<<< Dollars>>>
      PHDollar dolls_tooSmall( 0.0078 );
      PHDollar dolls_large( 9999999.99 );
      PHDollar dolls_unNormalized( 1.23456 );
      PHDollar dolls_already_Normalised( 1.56 );
      PHDollar dolls_from_tick1( ticks_negative.tickValueDollarsPerUnit() );
      PHDollar dolls_from_tick2( ticks_negative.tickValueDollarsForGivenNumLots( lots_already_Normalised ) );

      myLogger.logINFO(  "\r\n\ndolls_tooSmall: "           + dolls_tooSmall.toString() );
      myLogger.logINFO(  "dolls_large: "              + dolls_large.toString() );
      myLogger.logINFO(  "dolls_unNormalized: "       + dolls_unNormalized.toString() );
      myLogger.logINFO(  "dolls_already_Normalised: " + dolls_already_Normalised.toString() );
      myLogger.logINFO(  "dolls_from_tick1: " + dolls_from_tick1.toString() );
      myLogger.logINFO(  "dolls_from_tick2: " + dolls_from_tick2.toString() );
*/   


/*
   //Add 'risk' (returns Ticks-width of risk) to PHTicks
   //Size the Lot (given Ticks-width of risk)
   
      PH_FX_PAIRS eDummyVal = -1;
      PH_FX_PAIRS eSymbol = StringToEnum( Symbol(), eDummyVal );

      
      myLogger.logINFO( StringFormat( "<<<PHTicks>>>  value = 1.23456, Symbol: %s", eSymbol ) );
      PHTicks ticks_buyTest( 1.23456, eSymbol );
      string sResult = ticks_buyTest.toString();
      myLogger.logINFO(  StringConcatenate( "ticks_buyTest: ", sResult, "\r\n\n"  ) );

      myLogger.logINFO( StringFormat( "<<<PHTicks>>>  value = TBD, Symbol: %s", eSymbol ) );
      PHTicks ticks_ADTRx10dayCCPriceMoveWidth();
      ticks_ADTRx10dayCCPriceMoveWidth.calcStopLossWidth_10dATRx3( eSymbol );
      sResult = ticks_ADTRx10dayCCPriceMoveWidth.toString();
      myLogger.logINFO(  StringConcatenate( "StopLossWidth_10dATRx3: ", sResult, "\r\n\n"  ) );


/*      
      PHTicks Ticks_StopLossWidth = ticks_buyTest.calcStopLossWidth10dATRx3( Symbol() );
      myLogger.logINFO(  "ticks_buyTest: "       + ticks_buyTest.toString() );
      myLogger.logINFO(  "Ticks_StopLossWidth: " + Ticks_StopLossWidth.toString() );
*/   
  }
//+------------------------------------------------------------------+

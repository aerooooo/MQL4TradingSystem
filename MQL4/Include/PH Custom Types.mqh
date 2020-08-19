
//Used by Prepreocessor to detect whether this include file has already been included
#define _PHCustomTypes 1

#define _TODAY      0
#define _YESTERDAY  1     //You must not (cannot) work with the current bar's prices (since High/Low/Close all be set to the OPEN price!). 
                          //So everything's calculated from YESTERDAY backwards.
#define _TWODAYSAGO 2

#define _SL10dATRx3_iATRPeriod 10
#define _SL10dATRx3_dATRMultiplier (2.9)
//const double PHTrade::SLMAE_dStopLossWidth.Price = 0.02;  //MAE Constant (not used)



#ifndef _PHLogger
   #include <PHLogger.mqh>
#endif


enum PH_FX_PAIRS
  {
   EURUSD,
   GBPUSD,
   AUDUSD,
   NZDUSD,
   USDJPY,
   USDCHF,
   USDCAD
  };


//The integer numbers match the respective "Order Properties" Codes for the OrderSend() function
enum PH_ORDER_TYPES
  {
   ORDER_BUY            = 0,
   ORDER_SELL,
   ORDER_BUYLIMIT,
   ORDER_SELLLIMIT,
   ORDER_BUYSTOP,
   ORDER_SELLSTOP
  };


enum PH_ENTRY_REASONS
  {
   ENTRY_not_specified  = 400,  //shouldn't ever see this
   ENTRY_RANDOMCOINFLIP,
   ENTRY_MA_CROSSOVER,
   ENTRY_ADX,
   ENTRY_PYRAMID,
   ENTRY_ADDTOPOS,
   ENTRY_INTRADAY
  };

enum PH_EXIT_REASONS
  {
   EXIT_not_specified  = 500, //means "The prior setting is probably valid for the exit, and so I don't want you to overwrite the reason"
   EXIT_MA_CROSSOVER,
   EXIT_MAE_STOP,
   EXIT_2xDTR_STOP,           //the price moved two-times yesterday's DTR...in a single day!
   EXIT_EVEN_STOP,            //Stop was moved to break-even
   EXIT_PROFIT_RETAIN,
   EXIT_INTRADAY,
   EXIT_END_OF_TEST,
   EXIT_10dATRx3_STOP,        //three-times the ten-day ATR (plus the spread)
   EXIT_3wATRx2_STOP          //two-times the three-week ATR (plus the spread)
  };


enum PH_TRADE_STATUS
  {
   TRDSTATUS_WAITINGTOOPEN   = 600,
   TRDSTATUS_ASSUMEDOPEN,
   TRDSTATUS_WAITINGTOCLOSE,
   TRDSTATUS_CLOSED
  };



/*
enum PH_INITIAL_STOPLOSS_ALGORITHM {
   STPLSSALGO_ADTR       = 600,
   STPLSSALGO_MAE        = 601,
   STPLSSALGO_DISABLED   = 602
   };
*/



//+------------------------------------------------------------------+
//| String to Enumeration convertor
//|
//| Example usage:
/*
   string sVal = "USDJPY";
   PH_FX_PAIRS eVal;
   enum eSymbol = EnumToString( eVal = StringToEnum( sVal, eVal ) ) );
*/
//| 
//+------------------------------------------------------------------+
template<typename T>
T StringToEnum(string str,T enu)
  {
   for(int i=0;i<256;i++)
      if(EnumToString(enu=(T)i)==str)
         return(enu);
//---
   return(-1);
  }


enum PH_OBJECT_STATUS
  {
   OBJECT_UNITIALIZED,
   OBJECT_PARTIALLY_INITIALIZED,
   OBJECT_FULLY_INITIALIZED
  };






//+------------------------------------------------------------------+
//| PHDecimal  (class)
//|
//| A Class that stores it's decimal figures as Long!
//|  e.g. the value 150.56 would be stored in a Long as '15056'
//|
//|  The size of MQL4's LONG type is 8 bytes (64 bits). The minimum value is -9,223,372,036,854,775,808, the maximum value is 9,223,372,036,854,775,807 - effectively giving me 19 digits!)
//|   (Whereas The size of MQL's INT type is 4 bytes (32 bits). The minimal value is -2,147,483,648, the maximum value is 2,147,483,647 - which would only give me 10 digits to play with)
//|
//| It provides the following against given/supplied Doubles (I haven't implemented Class-dependant methods for that yet)
//|   * Addition
//|   * Substraction
//|   * Multiplication
//|   * Division
//|   * Comparison 
//|
//| The *only* safe way to accss the internall-held value is via the 'toNormalizedDouble()' method
//| (Even the 'toString()' method calls it first)
//| 
//|
//| This is actually an Abstract Class - but I can't get the compiler to recognize this
//| ...so I'll make the class UNUSUABLE - the Constructor won't take parameters and I'll have no 'set' methods!!!
//|
//+------------------------------------------------------------------+
#define _MAX_PRECISION 10

class PHDecimal {
   public:
      //Public Attributes
      PH_OBJECT_STATUS  _eStatus;   //I should make this private and only accessable via a "is" method, but Hey (shrug)
      
   protected:
      //Protected Attributes
      long              _lUnits;       // The decimal value (Stored as a Long)
      int               _iPrecision;   // Precision of your value.
      
   public:
      //Public Methods
         //Constructors (Abstract Class)
                           PHDecimal::PHDecimal( const double dInitialUnits, const int iPrecision );

                  void     PHDecimal::setValue( const double dInitialUnits, const int iPrecision );
                  void     PHDecimal::unsetValue();
                  void     PHDecimal::add( const double dAddUnits );
                  void     PHDecimal::subtract( const double dSubUnits );
                  void     PHDecimal::multiply( const double dMultiplicationUnits );
                  void     PHDecimal::divide( const double dDivisionUnits );
                  bool     PHDecimal::compare( const double dComparitorUnits );
                  double   PHDecimal::toNormalizedDouble() const;

      //Will need to be overidden ('cos of "2dp")
                  string   PHDecimal::toString() const 
                           { return( sFmt2dp( toNormalizedDouble() ) ); };

   private:
      //Private methods
         double   PHDecimal::prenormalizeOperand_round( const double dOperand ) const;
      
}; //end Class PHDecimal

/*
   //+------------------------------------------------------------------+
   //| PHDecimal - DUMMY Constructor (Unitialized/Empty)
   //|
   //| At one point I tried to turn this into an Abstract Class - but I couldn't 't get the compiler to recognize this
   //| ...so I'll made the class UNUSUABLE by having only this one Constructor that couldn't take any values  ;o)
   //| 
   //| (Now I'm just keeping the code around for good measure)
   //|
   //+------------------------------------------------------------------+
   PHDecimal::PHDecimal() 
   {
      this._eStatus    = OBJECT_UNITIALIZED;
      this._lUnits     = NULL;
      this._iPrecision = NULL;
   };  //end Constructor
*/

   //+------------------------------------------------------------------+
   //| PHDecimal - Constructor #1 (Elemental)
   //|
   //+------------------------------------------------------------------+
   PHDecimal::PHDecimal( const double dInitialUnits, const int iPrecision ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dUnits: %g, iPrecision: %i } ", dInitialUnits, iPrecision ) );
      
      if ( iPrecision > _MAX_PRECISION ) {
         unsetValue();
         myLogger.logERROR( StringFormat( "Precision cannot be greater than %i", _MAX_PRECISION ) );
      } else {
         setValue( dInitialUnits, iPrecision );
         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } //end if
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - SetValue (Value and Position)  [using Atomic Parameters]
   //|
   //| Sets both the Units and Precision
   //| Called by the Constructor and when manually changing a value
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::setValue( const double dInitialUnits, const int iPrecision )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dUnits: %g, iPrecision: %i } ", dInitialUnits, iPrecision ) );
      
      this._eStatus    = OBJECT_FULLY_INITIALIZED;
      this._iPrecision = iPrecision;

      double dPrecisionPosMultiplier = MathPow( 10, this._iPrecision );
      double dIntResult = dInitialUnits * dPrecisionPosMultiplier;
      this._lUnits     = (int) dIntResult;

      myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - UnSetValue
   //|
   //| Unsets both the Units and Precision
   //| Also called by PHDecimals' Constructor when it detects an invalid percentage (<0 or >100)
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::unsetValue()
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      
      this._eStatus    = OBJECT_UNITIALIZED;
      this._lUnits     = NULL;
      this._iPrecision = NULL;

      myLogger.logINFO( "No params. Object has been unintialized. Values set to NULL" );
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - Addition
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::add( const double dAddUnits ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dAddUnits: %g } ", _lUnits, dAddUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         // Determine the number in multiples of the least significant digit (for 2dp, the number must be in multiples of 0.01)
         double dNormalizedOperand = prenormalizeOperand_round( dAddUnits );
         
         // Step #2: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         long lNormalizedValue = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));
         myLogger.logDEBUG( StringFormat( "Step#2 NormalizedValue [long]: %g ", lNormalizedValue ) );

         // Step #3: Finally, perform the operation (add) - apply the Operand to the Class' value
         this._lUnits += lNormalizedValue;

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   };  //end add()



   //+------------------------------------------------------------------+
   //| PHDecimal - Subtraction
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::subtract( const double dSubUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dSubUnits: %g } ", _lUnits, dSubUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         // Determine the number in multiples of the least significant digit (for 2dp, the number must be in multiples of 0.01)
         double dNormalizedOperand = prenormalizeOperand_round( dSubUnits );

         
         // Step #2: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         long lNormalizedValue = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));
         myLogger.logDEBUG( StringFormat( "Step#2 NormalizedValue [long]: %g ", lNormalizedValue ) );


         // Step #3: Finally, perform the operation (subtract) - apply the Operand to the Class' value
         this._lUnits -= lNormalizedValue;

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   }; //end sub()



   //+------------------------------------------------------------------+
   //| PHDecimal - Multiplication
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::multiply( const double dMultiplicationUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dMultplicationUnits: %g } ", _lUnits, dMultiplicationUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         // Determine the number in multiples of the least significant digit (for 2dp, the number must be in multiples of 0.01)
         double dNormalizedOperand = prenormalizeOperand_round( dMultiplicationUnits );

         
         // Step #2: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         long lNormalizedValue = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));
         myLogger.logDEBUG( StringFormat( "Step#2 NormalizedValue [long]: %g ", lNormalizedValue ) );


         // Step #3a: Finally, perform the operation (multiplication) - apply the Operand to the Class' value
         long lOverMultipliedValue = (this._lUnits * lNormalizedValue);
         myLogger.logDEBUG( StringFormat( "Step#3a Over-Multiplied Value [long]: %g ", lOverMultipliedValue ) );

         // Step #3b: Unfortunately, you've not only multiplied the Units, but also the Precision (by 2dp). 
         // So shift the intermediate result right by '_iPrecision' digits
         this._lUnits = (lOverMultipliedValue / (long) MathPow( 10, this._iPrecision ));  //e.g. divide by 100 (for 2dp)

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Multiplication cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   }; //end multiply()



   //+------------------------------------------------------------------+
   //| PHDecimal - Division
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::divide( const double dDivisionUnits )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dDivisionUnits: %g } ", _lUnits, dDivisionUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         // Determine the number in multiples of the least significant digit (for 2dp, the number must be in multiples of 0.01)
         double dNormalizedOperand = prenormalizeOperand_round( dDivisionUnits );

         
         // Step #2: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         long lNormalizedValue = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));
         myLogger.logDEBUG( StringFormat( "Step#2 NormalizedValue [long]: %g ", lNormalizedValue ) );


         // Step #3: Finally, perform the operation (division) - apply the Operand to a temporary variable*
         // Note that the temp variable also needs a double to temporarily handle the decimals
         double dDividedResult = (this._lUnits / (double) lNormalizedValue);     //e.g. 1.666666666
         myLogger.logDEBUG( StringFormat( "Step#3 dDividedResult [double]: %g ", dDividedResult ) );

         // Step #4: I'll also normalize the result to the correct DPs - rounding as necessary
         double dNormalizedResult = prenormalizeOperand_round( dDividedResult );  //e.g. 1.67 (@ 2dp)
         myLogger.logDEBUG( StringFormat( "Step#4 dNormalizedResult [double]: %g ", dNormalizedResult ) );

         // Step #5: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         lNormalizedValue = (long) ( dNormalizedResult * MathPow( 10, this._iPrecision ));
         myLogger.logDEBUG( StringFormat( "Step#5 Re-NormalizedValue [long]: %g ", lNormalizedValue ) );

         this._lUnits = lNormalizedValue;

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Division cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   }; //end divide()



   //+------------------------------------------------------------------+
   //| PHDecimal - Comparison
   //|
   //| In theory, this method is *superior* to attempting to COMPARE two DOUBLE values!
   //|
   //+------------------------------------------------------------------+
   bool PHDecimal::compare( const double dComparitorUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "param { dComparitorUnits: %g } ", dComparitorUnits ) );

      bool isEqual = false;
      
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         double dNormalizedOperand = prenormalizeOperand_round( dComparitorUnits );
         
         // Step #2: "Push"/cast the Operand into a Long
         long lNormalizeValue = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));


         // Step #3: Finally, perform the operation (comparison) - apply the Operand to the Class' value
         if ( this._lUnits == lNormalizeValue )
            isEqual = true;

         myLogger.logINFO( StringFormat( "final { this._lUnits: %g, lNormalizeValue: %i } ", this._lUnits, lNormalizeValue ) );

      }
      
      return( isEqual );
      
   }; //end comparison()




   //+------------------------------------------------------------------+
   //| PHDecimal - toNormalizedDouble
   //|
   //| This should be the *only* way to retrieve the value 
   //|  (although other methods can be a wrapper to this one)
   //| Actually, 'normalization' (i.e. ensuring only multiples of 0.01) is unnecessary, since the _lUnits is already normalised to 2dDPs  e.g. "1234" => 12.34
   //| But I'm keeping the name for consistency with my higher-level classes
   //|
   //| So in reality, rather than Normalizing, the only work to do here is >>>simply shifting _lUnits 2 digits to the right!<<<
   //|
   //+------------------------------------------------------------------+
   double   PHDecimal::toNormalizedDouble() const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dRet;
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {
      
         double dUnits = (double) this._lUnits;
         double dPrecisionMultiples = MathPow( 10, -this._iPrecision );  //Note the >>>minus power<<< i.e. 10^2 becomes 10^-2.  This will return my 'multiples of least significant digit' e.g. 0.01
         dRet = dUnits * dPrecisionMultiples;

         myLogger.logINFO( StringFormat( "final { dRet: %g, _iPrecision: %i } ", dRet, _iPrecision ) );
      } else {
         myLogger.logERROR( "No value to return on an uninitialized Object!" );
         dRet = NULL;
      }

      return( dRet );
   };  //end toNormalizedDouble()




   //+------------------------------------------------------------------+
   //| PHDecimal   prenormalizeOperand_round
   //|
   //| Determine the number in multiples of the least significant digit
   //|   e.g. for 2dp, the number must be in multiples of 0.01
   //|
   //| This instance will >>>Round to the nearest digit<<<   e.g. 0.238 becomes 0.24 (for 2dp).  
   //|   Alternative methods might StepUp (0.232 forced up to 0.24) or StepDown/Truncate (0.238 forced down to 0.23)
   //|
   //+------------------------------------------------------------------+
   double PHDecimal::prenormalizeOperand_round( const double dOperand ) const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dNormalizedOperand;
      {
         double dPrecisionMultiples = MathPow( 10, -this._iPrecision );  //Note the minus power i.e. 10^2 becomes 10^-2.  This will return my 'multiples of least significant digit' e.g. 0.01
         dNormalizedOperand = MathRound( dOperand / dPrecisionMultiples ) * dPrecisionMultiples; //actually performs the normalization.  e.g. 0.238 becomes 0.24 (for 2dp)
         myLogger.logINFO( StringFormat( "final: Pre-NormalizedOperand - Rounded [double]: %g ", dNormalizedOperand ) );
      };

      return( dNormalizedOperand );   
   };













//+------------------------------------------------------------------+
//| PHPercent
//|
//| Admittidly, a rather simple numerical object
//| But one who's rules mean that it can only exist between 1 and 100
//| So it kinda has that login 'baked in' and *you don't have to worry about it*
//|
//+------------------------------------------------------------------+
class PHPercent : public PHDecimal {

      //Public Methods
      public:
                  PHPercent::PHPercent( const double dFigure, const int iPrecision ) : PHDecimal( dFigure, iPrecision ) { validateFigure(); } ;   //Supply a decimal between 0.0 and 100.0
//                  PHPercent::setPercent( const double dPercent );
         double   PHPercent::getFigure()  const { return this.toNormalizedDouble(); };            //Returns a value between 0    and 100
         double   PHPercent::getPercent() const { return PHDecimal::toNormalizedDouble()/100; };  //Returns a value between 0.00 and   1.00
         
     protected:
         void     PHPercent::validateFigure();

}; //end Class

/* temporarily hide...

   //+------------------------------------------------------------------+
   //| PHPercent - Constructor (Elemental)
   //|
   //+------------------------------------------------------------------+
   PHPercent::PHPercent( const double dFigure, const int iPrecision )
*/
   //+------------------------------------------------------------------+
   //| PHPercent - validateFigure
   //|
   //| I would usually perform validation within the Constructor, but since
   //| this has been subclassed from the PHDecimal class, I can't stop the 
   //| Base class' Constructor from setting the values first!
   //|
   //| So I'll allow the Base class Constructor to run (and set the Value/Precision)
   //| and then come along, perform validation, and either 
   //|   a) allow the values set by the Base Constructor to stand as-is
   //|   b) Warn the user (again, allowing the values set by the Base Constructor to stand as-is)
   //|   c) Override the Value with 100% if set out-of-bounds (i.e. <0 or >100)
   //|
   //+------------------------------------------------------------------+
   void PHPercent::validateFigure()
   {   
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dFigure = this.toNormalizedDouble();
   
      if ( (dFigure > 0) && (dFigure < 1) )
         myLogger.logWARN( StringFormat( "Percentages can be set between 0 and 100. If you meant to set a percentage between 0%% and 1%% then fine. Otherwise, if you meant %g%%, set it as %g instead", (dFigure*100), (dFigure*100) ) );
      
      if ( ( dFigure < 0 ) || ( dFigure > 100 ) ) {
         myLogger.logERROR( StringFormat( "params passed { value: %g } is out of bounds - setting to 100.00 (2dp)", dFigure ) );
         PHDecimal::setValue( 100, 2 );
      } //end if

   } //end method


















class PHTicks 
{
      //<<<Private Attributes>>>
      private:
         //int    _iTicks;    //always an integer, a count of whole ticks
         double      _dTicks;
         PH_FX_PAIRS _eSymbol;

//         PHDollar    *_DollarArray[];  //For manually-created PHDollars - Necessary to use Pointers - needed for loop and Delete()
         PHTicks     *_TicksArray[];    //For manually-created PHTicks - Necessary to use Pointers - needed for loop and Delete()


      //<<<Private Methods>>>
      private:
//         void     PHTicks::addToDollarArray( PHDollar &oDollar );
         void     PHTicks::addToTicksArray(  PHTicks  &oTick );

      //<<<Public Methods>>>
      public:
                  //Constructors
                  PHTicks::PHTicks( const double dTicks, const PH_FX_PAIRS eSymbol );
                  PHTicks::PHTicks( const PH_FX_PAIRS eSymbol ); //(Previously known as the "dCalcStopLossWidth_10dATRx3()" function)
                  PHTicks::PHTicks( const PHTicks& that );

                  PHTicks::~PHTicks();
         double   PHTicks::toNormalizedDouble() const;
/* temp removed
         PHDollar PHTicks::tickValueDollarsPerUnit();
         PHDollar PHTicks::tickValueDollarsPerStdContract();
         PHDollar PHTicks::tickValueDollarsForGivenNumLots( PHLots &oLots );
*/
         string   PHTicks::toString()
                     const { return( sFmtDdp( toNormalizedDouble() ) ); };
         PHTicks  PHTicks::calcStopLossWidth_10dATRx3( const PH_FX_PAIRS eSymbol );

}; //end Class


   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #1 (Elemental)
   //|
   //| (Ignores initializing the Object Arrays - the initialization that occurs in the Class structre is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const double dTicks, const PH_FX_PAIRS eSymbol ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logDEBUG( StringFormat( "params (Constructor #1) { value: %s, sSymbol: %s }", sFmtDdp(dTicks), EnumToString( eSymbol ) ) );

      //Set my mandatory Class Attributes
      this._eSymbol = eSymbol;
      this._dTicks = MathAbs( dTicks );     //In case I get sent a negative value
   }; //end PHTicks:: Constructor


   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #2 (Copy Object)
   //|
   //| Copies the Tick Value and Symbol over
   //| (Ignores initializing the Object Arrays - the initialization that occurs in the Class structre is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const PHTicks& that ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double      dThatTicks  = that._dTicks;
      PH_FX_PAIRS eThatSymbol = that._eSymbol;

      myLogger.logDEBUG( StringFormat( "Copying PHTick object  (Constructor #2) { dTicks: %s, sSymbol: %s }", sFmtDdp(dThatTicks), EnumToString( eThatSymbol ) ) );

      //Set my mandatory Class Attributes
      this._dTicks = dThatTicks;
      this._eSymbol = eThatSymbol;

      /*  objects that I *know* I have dynamically instanciated (using new() ) do not seem to appear as Dynamically Instanciated objects!!!  Unable to check!
    
         if( CheckPointer( GetPointer( that ) ) == POINTER_DYNAMIC ) {   //Aside: Needed to GetPointer, before was able to check it for the Object 'instanciation type'
            myLogger.logWARN( StringConcatenate( "The PHTick object { dTicks: %.8f, sSymbol: %s } is DYNAMICALLY ALLOCATED", dThatTicks, sThatSymbol ) );
            //PHTicks::addToTicksArray( GetPointer( that ) );     //Unable: "Constant variable canot be passed as reference" => Remove 'const'?
         } //end if
      */

   }; //end PHTicks:: Constructor




   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #3 (Ten-Day Average Daily True Range x 3)
   //| (Previously known as the "dCalcStopLossWidth_10dATRx3()" function)
   //|
   //| This is a rather special constructor. It doesn't take a Tick value - since it will calculate one itself.
   //|
   //| Notes:
   //|   >> This is the *width* of the move allowed, which is very different from the absolute 'StopLoss Price Level' (which gets set at a later step)
   //|   >> Note that the StopLoss Width doesn't take the spread into account per se.  That happens by choosing to subtracting it (for a long) from the Ask (not included), or Bid (included) price later.
   //|   >> Returns a value in UoM: Ticks.  Since a Tick is the smallest possible move, it actually returns an INT
   //|
   //|   >> This particular algorithm uses the ADTR. Alternatives exist (such as MAE)!
   //|   >> Even though a Constrctor, it ignores the Object Arrays - the initialization that occurs in the Class structre is sufficient
   //|
   //| Gets called by:
   //|   a) early during the 'OpenTradeAtMarket()' function to determine the risk (a Price Width)
   //|   b) then again by the 'dCalcStopLossPrice_10dATRx3()' function to re-calculate the absolute StopLoss leve (a Price Level)
   //|
   //| Calls:
   //|   -
   //| (Ignores initializing the Object Arrays - the initialization that occurs in the Class structre is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const PH_FX_PAIRS eSymbol ) 
   {   //(Previously known as the "dCalcStopLossWidth_10dATRx3()" function)
   
      LLP(LOG_INFO)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

      string sSymbol = EnumToString( eSymbol );    //Set the string representation since I'll be needing it later anyway
      myLogger.logDEBUG( StringFormat( "param(s) (Constructor #3) { eSymbol: %s }", sSymbol ) );

      //Set my mandatory Class Attributes
      //   In this case, I'm only able to set the Symbol at this stage.  I'll calculate the Ticks and set it by the end of the method
      this._eSymbol = eSymbol;
   
      // Calculate the Average Daily True Range on Daily Bars, for a given symbol/period  (x periods back, starting from yesterday)
      // WARNING: I'm using the *Terminal's* Daily periods (not mine)..but who cares for an ADTR, right?!
         HideTestIndicators(true);
   
      /* Code to prove the ADTR is working
         int stPer = 70;
   
            double dADTR_d1 = iATR( sSymbol, PERIOD_D1, 1, stPer );
            double dADTR_d2 = iATR( sSymbol, PERIOD_D1, 2, stPer );
            double dADTR_d3 = iATR( sSymbol, PERIOD_D1, 3, stPer );
   
         datetime Days[];
         datetime dtDy;
         string sDy;
         double High[],Low[];
         double low, high, diff;
   
         ArraySetAsSeries(Days,true);
         ArraySetAsSeries(Low,true);
         ArraySetAsSeries(High,true);
   
         CopyTime(sSymbol,PERIOD_D1,stPer,3,Days);
         CopyLow(sSymbol,PERIOD_D1,stPer,3,Low);
         CopyHigh(sSymbol,PERIOD_D1,stPer,3,High);
   
         for(int i = 0; i < 3; i++) {
            dtDy = Days[i];
            sDy = TimeToStr( dtDy, TIME_DATE||TIME_SECONDS);
            high = High[i];
            low = Low[i];
            diff = high-low;
               DebugBreak();
            }
   
          //Result
          for example on May 04, 2020, the EURUSD (Daily Bars) Opening Price gapped down from May 03's Close:
            The simple difference between the High and Low on this date was = 0.007870  0.0078699999999998
            However, the correct ADTR was to take the difference between May 03's Close and May 04's Low = 1.09802 - 1.08956 = 0.00846
            The iADTR reported it correctly (with the gap)
   
      */
      ENUM_TIMEFRAMES ePeriod = PERIOD_D1;
   
      myLogger.logDEBUG( StringFormat( "Constants: 10dATRx3 Averaging Period: %i of %s;  10dATRx3 Multiplier: %f \r\n", _SL10dATRx3_iATRPeriod, EnumToString(ePeriod), _SL10dATRx3_dATRMultiplier ) );
   
      //"Price Width" #1 - a simple ADTR
      //Begin by calculating the ADTR for a (10 x Day) period for my Market/Symbol.  Declare a new Tick Object of the resultant "price width"
      PHTicks oADTR_CCPriceMoveWidth( iATR(sSymbol, ePeriod, _SL10dATRx3_iATRPeriod, _YESTERDAY), _eSymbol   );     // e.g. 0.009339
      myLogger.logDEBUG( StringFormat( "ATR (Period: %i): %s",    _SL10dATRx3_iATRPeriod, oADTR_CCPriceMoveWidth.toString() ) );
      HideTestIndicators(false);
   
      //"Price Width" #2 - The ADTR multiplied by a arbitary factor
      //Given the ADTR, now calculate the Stop Loss Width (as a multiple of the ADTR). UoM is a width in terms of the Country Currency's price
      // Set the value in my Class' Attribute
      this._dTicks = ( oADTR_CCPriceMoveWidth.toNormalizedDouble() * _SL10dATRx3_dATRMultiplier );     // e.g. 0.009339 x 2.9 = 0.02708
      myLogger.logINFO( StringFormat( "RESULT-> StopLoss Width (in Counter Currency Price): %s \r\n", this.toString() ) );
         /* Deprecated... My new way is to simply store the result in the Class Attribute!
            This was the original way...
            // Again since this is also a Price Width, declare a new Tick Object - but this time declare it as an Object Pointer (necesaary so that it can be returned by my function)
            PHTicks *stopLossWidth = new PHTicks( ( oADTR_CCPriceMoveWidth.toNormalizedDouble() * _SL10dATRx3_dATRMultiplier ), sSymbol );     // e.g. 0.009339 x 2.9 = 0.02708
            PHTicks::addToTicksArray( stopLossWidth );   //Make a note of it - for eventual manual cleanup
            myLogger.logDEBUG( StringFormat( "RESULT-> StopLoss Width (in Counter Currency Price): %s", stopLossWidth.toString() ) );
            ...
            return( stopLossWidth );
         */


/*   
      PriceMove_CC dTickSize = SymbolInfoDouble(sSymbol, SYMBOL_TRADE_TICK_SIZE);   // e.g. 0.00001 (for a 5-digit currency pair)
      myLogger.logDEBUG(StringFormat("Tick Size (for %s): %f",     sSymbol, dTickSize));
   
   //If I wanted to convert this into Pips,  then I would divide by 0.0001 (for a 4-digit ccy pair) = 270.8 Pips
   //  This would result in a 'StopLossWidth_Pips'  i.e. A StopLoss Width...in units of Pips
   
   //DebugBreak();
   
      PriceMove_Ticks   iStopLossWidth_Ticks = dStopLossWidth_CCPrice / dTickSize;     // e.g. 2,708 Ticks (Note I'm deliberately casting to an INT)
   //  This results in a 'StopLossWidth_Ticks'  i.e. A StopLoss Width...in units of Ticks
      myLogger.logINFO(StringFormat("dStopLossWidth (in Ticks): %i",     iStopLossWidth_Ticks));
   
      return(iStopLossWidth_Ticks);
*/


   }; //end Constructor #3  (Ten-Day Average Daily True Range x 3 / "dCalcStopLossWidth_10dATRx3()" function)

   




   //+------------------------------------------------------------------+
   //| PHTicks - Destructor
   //|
   //+------------------------------------------------------------------+
   PHTicks::~PHTicks() {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logDEBUG( "Destructor" );

      int   iObjDelCount = 0;
      
      /*
      int   iCurrentArraySize = ArraySize( _DollarArray );
      myLogger.logDEBUG( StringFormat( "There are %i elements in the _DollarArray that require deleting.", iCurrentArraySize ) );
      for( int i = 0; i < iCurrentArraySize; i++ ) { 
         //PHDollar *doll = _DollarArray[ i ];   //Works... (object can be referenced through 'doll' -- but NT '*doll'!!!  But not necessary for success.
         if( CheckPointer( _DollarArray[ i ] ) == POINTER_DYNAMIC )  { 
            myLogger.logDEBUG( StringConcatenate( "Deleting <PHDollar> Object ", _DollarArray[ i ] ) );
            //Print("Dynamyc object ",item.Identifier()," to be deleted"); 
            delete _DollarArray[ i ] ; 
            iObjDelCount++;
         } //end if
      } //end for 
      */

      int iCurrentArraySize = ArraySize( _TicksArray );
      myLogger.logDEBUG( StringFormat( "There are %i elements in the _TicksArray that require deleting.", iCurrentArraySize ) );
      for( int i = 0; i < iCurrentArraySize; i++ ) { 
         if( CheckPointer( _TicksArray[ i ] ) == POINTER_DYNAMIC )  { 
            myLogger.logDEBUG( StringConcatenate( "Deleting <PHTicks> Object ", _TicksArray[ i ] ) );
            delete _TicksArray[ i ] ; 
            iObjDelCount++;
         } //end if
      } //end for 

      myLogger.logINFO( StringFormat( "%i objects were manually deleted.", iObjDelCount ) );
   }; //end Destructor


   //+------------------------------------------------------------------+
   //| PHTicks - toNormalizedDouble
   //|
   //| Ensures that the Tick value (either a point/level in the market, or a width of Ticks)
   //| is a multiple of SYMBOL_TRADE_TICK_SIZE (typically 0.00001 for a 5-digit market)
   //|
   //| Returns: double
   //+------------------------------------------------------------------+
   double   PHTicks::toNormalizedDouble() const
   { 
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      myLogger.logDEBUG( StringFormat( "_dTicks: %s", sFmtDdp(_dTicks) ) );
   
         /*    https://www.mql5.com/en/forum/135345#comment_3437165
         double  tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
         nowOpen = MathRound(nowOpen/tickSize)*tickSize;
         */
      double dTickSizeInMarket = SymbolInfoDouble( EnumToString( _eSymbol ), SYMBOL_TRADE_TICK_SIZE );  //e.g. 0.0001
      myLogger.logDEBUG( StringFormat( "_dTickSizeInMarket: %s", sFmtDdp(dTickSizeInMarket) ) );
     
      double dNormalizedTicks = MathRound( _dTicks / dTickSizeInMarket) * dTickSizeInMarket;
      myLogger.logDEBUG( StringFormat( "dNormalizedTicks: %s \r\n", sFmtDdp(dNormalizedTicks) ) );

      return dNormalizedTicks; 
   };
   
   

/* temp removed.  Resetablish - as needed...

   //Note these were originally Private Class Attributes:  - I think that was probably too static and they should probably be pushed into a method so that the rates can be 'Refreshed' upon use.
         double _dTickValueInMarket; //e.g. $1.00
         double _tickValueDollarsPerUnit;   //e.g. $1.00
         double _tickValueDollarsPerStdContract;   //e.g. $1.00
         double _dContractSize;      //e.g. 100,000 units

   //Note these were originally calculated in the Constructor:  - I think that was probably too static and they should probably be pushed into a method so that the rates can be 'Refreshed' upon use.
      _dTickValueInMarket  = SymbolInfoDouble(sSymbol, SYMBOL_TRADE_TICK_VALUE);
      _dContractSize       = SymbolInfoDouble(sSymbol, SYMBOL_TRADE_CONTRACT_SIZE);

      _tickValueDollarsPerUnit = _dTickValueInMarket / _dTickSizeInMarket / _dContractSize;
      _tickValueDollarsPerStdContract = _dTickValueInMarket / _dTickSizeInMarket;

      myLogger.logDEBUG( StringFormat( "_dTickValueInMarket: %.8f", _dTickValueInMarket ) );
      myLogger.logDEBUG( StringFormat( "_tickValueDollarsPerUnit: %.8f", _tickValueDollarsPerUnit ) );
      myLogger.logDEBUG( StringFormat( "_tickValueDollarsPerStdContract: %.8f", _tickValueDollarsPerStdContract ) );



   PHDollar PHTicks::tickValueDollarsPerUnit()
   {
      //  True TickValue in $ = MODE_TICKVALUE ÷ MODE_TICKSIZE

      PHDollar *objInst1 = new PHDollar( _tickValueDollarsPerUnit );
      PHTicks::addToDollarArray( objInst1 );
      //return( GetPointer(objInst1) );
      return( objInst1 );
   };
   
   PHDollar PHTicks::tickValueDollarsPerStdContract()
   {
      //  True TickValue in $ = MODE_TICKVALUE ÷ MODE_TICKSIZE

      PHDollar *objInst1 = new PHDollar( _tickValueDollarsPerStdContract );
      PHTicks::addToDollarArray( objInst1 );
      //return( GetPointer(objInst1) );
      return( objInst1 );
   };
   

   PHDollar PHTicks::tickValueDollarsForGivenNumLots( PHLots &oLots )
   {
      //  True TickValue in $ = MODE_TICKVALUE ÷ MODE_TICKSIZE


      double dLots = oLots.toNormalizedDouble();
      
      PHDollar *objInst1 = new PHDollar( _tickValueDollarsPerStdContract );
      PHTicks::addToDollarArray( objInst1 );
      //return( GetPointer(objInst1) );
      return( objInst1 );
   };
 
  
  
 
   void     PHTicks::addToDollarArray( PHDollar &oDollar ) {
      int   iCurrentArraySize = ArraySize( _DollarArray );
      ArrayResize( _DollarArray, (iCurrentArraySize+1) );
      _DollarArray[ iCurrentArraySize ] = GetPointer( oDollar );   //Appears (from testing) that GetPointer() is absolutely necessary!
   
   };
*/   
   
   void     PHTicks::addToTicksArray(  PHTicks  &oTick ) {
      int   iCurrentArraySize = ArraySize( _TicksArray );
      ArrayResize( _TicksArray, (iCurrentArraySize+1) );
      _TicksArray[ iCurrentArraySize ] = GetPointer( oTick );   //Appears (from testing) that GetPointer() is absolutely necessary!
   
   };
   
   

   
   




//Lots must be defined after Ticks  (I use Ticks in the methods)
class PHLots {
      // Will only return in correct multiple of Lot size (minimum of 0.01, in multiles of 0.01 and a maximum of 50)
      // Lots may be temporarily breach those rules within this class (while being calculated, for example) but ultimately must comply to the above rules
      
      //<<<Private Attributes>>>
      private:
         double      _dLots;
         PH_FX_PAIRS _eSymbol;
         double      _dVolumeMin, _dVolumeStep, _dVolumeMax, _StandardContractSize;

      //<<<Public Methods>>>
      public:
                  //Constructors
                  PHLots::PHLots( const double dValue, const PH_FX_PAIRS eSymbol );
                  PHLots::PHLots( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHPercent& oPercentageOfEquityToRisk );
         void     PHLots::PHLots0( const string sSymbol );

         double   PHLots::getVolumeMin()            const { return _dVolumeMin; };
         double   PHLots::getVolumeMax()            const { return _dVolumeMax; };
         double   PHLots::getVolumeStep()           const { return _dVolumeStep; };
         double   PHLots::getStandardContractSize() const { return _StandardContractSize; };


         const string PHLots::toString()
                     const { return( sFmt2dp( toNormalizedDouble() ) ); };
         const double PHLots::toNormalizedDouble() const;

}; //end Class

   //+------------------------------------------------------------------+
   //| PHLots - False Constructor #0 (Common/Environment (No Params))
   //|
   //+------------------------------------------------------------------+
   void  PHLots::PHLots0( const string sSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      //--- double value output in a compact format
      _dVolumeMin = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_MIN );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MIN = %g (minimal volume for a deal)", _dVolumeMin ) );
   
      //--- double value output in a compact format
      _dVolumeStep = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_STEP );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_STEP = %g (minimal volume change step)", _dVolumeStep ) );

      //--- double value output in a compact format
      _dVolumeMax = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_MAX );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MAX = %g (maximal volume for a deal)", _dVolumeMax ) );
      
      _StandardContractSize = SymbolInfoDouble( sSymbol, SYMBOL_TRADE_CONTRACT_SIZE );
      myLogger.logDEBUG( StringFormat( "SYMBOL_TRADE_CONTRACT_SIZE = %f", _StandardContractSize ) );
   };



   //+------------------------------------------------------------------+
   //| PHLots - Constructor #1 (Elemental)
   //|
   //+------------------------------------------------------------------+
   PHLots::PHLots( const double dValue, const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      
      string sSymbol = EnumToString( eSymbol );
      myLogger.logDEBUG( StringFormat( "passed params { dValue: %f, sSymbol: %s }\r\n", _dLots, sSymbol ) );

      //Call to Super()
      PHLots::PHLots0( sSymbol );

      //Set my mandatory Class Attributes
      this._dLots = dValue;     //potentially unNormalized!  (But the returned value will always be normalized before being Returned)
      this._eSymbol = eSymbol;

/*
      //--- double value output in a compact format
      _dVolumeMin = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_MIN );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MIN = %g (minimal volume for a deal)", _dVolumeMin ) );
   
      //--- double value output in a compact format
      _dVolumeStep = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_STEP );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_STEP = %g (minimal volume change step)", _dVolumeStep ) );

      //--- double value output in a compact format
      _dVolumeMax = SymbolInfoDouble( sSymbol, SYMBOL_VOLUME_MAX );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MAX = %g (maximal volume for a deal)", _dVolumeMax ) );
      
      _StandardContractSize = SymbolInfoDouble( sSymbol, SYMBOL_TRADE_CONTRACT_SIZE );
      myLogger.logDEBUG( StringFormat( "SYMBOL_TRADE_CONTRACT_SIZE = %f", _StandardContractSize ) );


      myLogger.logDEBUG( StringFormat( "final values { _dLots: %s, _eSymbol: %s, _dVolumeMin: %s, _dVolumeStep: %s, _dVolumeMax: %s }\r\n", sFmt2dp(_dLots), sSymbol, sFmt2dp(_dVolumeMin), sFmt2dp(_dVolumeStep), sFmt2dp(_dVolumeMax) ) );
*/
   }; //end PHLots:: Constructor



   //+------------------------------------------------------------------+
   //| PHLots - Constructor #2 (Derive num Lots given a StopLossWidth)
   //| (Previously known as the "sizePercentRiskModel()" function)
   //|
   //|  This starts by calculating the Risk Value Of 1.0x Lot. Then, after I have the precise number of Lots I'm going to trade, I'll call it again to get the Risk Value of 0.x lots
   //|
   //| 1. Take x% of Account Equity  (typically 1%)
   //| 2. Calculating the risk of taking one whole standard lot (1.0 Lot = 100,000 Units)
   //| 3. Calculate the ratio of one lot's worth divided by 1% Equity (it'll probably be a fraction of a lot)
   //|
   //| Calls:
   //|   dPriceMove2ValueCalculator()
   //|
   //+------------------------------------------------------------------+
   PHLots::PHLots( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHPercent& oPercentageOfEquityToRisk )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
   
      string sSymbol = EnumToString( eSymbol );
      myLogger.logDEBUG( StringFormat( "passed params { sSymbol: %s, StopLoss Width: %s, oPercentageOfEquityToRisk: %f }", sSymbol, oTicks_StopLossWidth.toString(), oPercentageOfEquityToRisk.getFigure() ) );

      //Call to Super()
      PHLots::PHLots0( sSymbol );


      // Step #1. Given x% of Account Equity  (typically 1%) [oPercentageOfEquityToRisk]
      //---------------------------------------------------------------------------------
      //The $ value of what would be at risk, in terms of Deposit Currency, if you were to place an order for one whole lot (100,000 units)
      //This is not the *price* of 1 x Lot. It's the Stop Loss Width Value of 1 x Standard Contract (1 x Lot of 100,000 of the base ccy)
      //...If I were to buy 1 x Standard Contract, this is how much equity I have decided is acceptable to lose before throwing in the towel
      //...But I'm not going to buy 1 x Standard Contract, I'm going to buy less!
   

      // Step#2. Calculating the risk of taking one whole standard lot (1.0 Lot = 100,000 Units)
      //-----------------------------------------------------------------------------------------
      // Get a *rough shot* at calculating the Risk by calculating my risk at the standard lot size (1.0 Lot = 100,000 Units)
      // (I probably won't be able to afford this, but my algorithm will later scale it down into lots of x0.01 automatically)
      PHLots   oLots( 1.0, eSymbol );
      PHDollar oRiskValueOf1Lot( eSymbol, oTicks_StopLossWidth, oLots );   //(Calling a non-default PHDollar Constructor)
      myLogger.logDEBUG( StringFormat( "Value of a %s Tick move with a %s x Contract: %s (Represents Risk)", oTicks_StopLossWidth.toString(), oLots.toString(), oRiskValueOf1Lot.toString() ) );
         
      //A subset of the entire Account that you are prepared to lose for this trade, in terms of Deposit Currency. Each trade should never risk more than this.
               //Money dMaxPermittedRiskValue;    
      //calculate "what I can afford to lose/risk each trade" (e.g. 1% of equity)
      PHDollar oMaxPermittedRiskValue( AccountEquity() * oPercentageOfEquityToRisk.getPercent() );    //1% of given Equity
      myLogger.logDEBUG(StringFormat("Max Permitted Risk: %s (%s%% of given Equity: %s)", sFmtMny(oMaxPermittedRiskValue.toNormalizedDouble()), sFmt2dp(oPercentageOfEquityToRisk.getFigure()), sFmtMny(AccountEquity())));

      // Step #3. Calculate the ratio of one lot's worth divided by 1% Equity (it'll probably be a fraction of a lot)
      //--------------------------------------------------------------------------------------------------------------
      //calculate the RATIO of "what I can afford to lose/risk each trade" (e.g. 1% of equity) divided by "the cost to open one whole Lot".
      //In this case the ratio directly becomes the "number of lots"!
      //This may result in a rounding up of the requested Lots, which *may* in turn *slightly* exceed my Max Permitted Risk, but not enough to care about
      this._dLots = NormalizeDouble( ( oMaxPermittedRiskValue.toNormalizedDouble() / oRiskValueOf1Lot.toNormalizedDouble() ), 2);
      myLogger.logINFO(StringFormat( "Number of Lots (adjusted as per Max Permitted Risk per Trade): %s (given a Stop Loss Width of %s)", this.toString(), oTicks_StopLossWidth.toString() ) );

   
   };
   
   

   //+------------------------------------------------------------------+
   //| PHLots - toNormalizedDouble
   //|
   //| Ensure the value held in the Class' Attribute (held in a non-normalised fashion by the way) returns only a figure that is
   //| a) less than the Maximum allowed Lots (Typically 50 in Forex)
   //| b) multiple of the allowed LOT_Steps (typically nultiples of 0.01)
   //| c) If less than than the Minimum allowed Lots (typically 0.01) then return a *zero*
   //|
   //| >>>The idea is that the *only* way to access the value held in the Class' Attribute is through *this method*.
   //|      For instance, to_String() invokes this method.
   //|
   //+------------------------------------------------------------------+
   const double PHLots::toNormalizedDouble() const
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logDEBUG( StringFormat( "initial _dLots: %f ", _dLots ) );

      //Attempt to nomalize first (in multiples of LOT_STEP).  Then afterwards check for out-of-range situations...
      double dLots = MathRound( _dLots / _dVolumeStep ) * _dVolumeStep;
         //His Code [https://mql4tradingautomation.com/mql4-calculate-position-size/]:     dLotSize = MathRound( LotSize / MarketInfo( Symbol(), MODE_LOTSTEP ) ) * MarketInfo( Symbol() , MODE_LOTSTEP );

      if ( dLots < _dVolumeMin )
         dLots = 0;
         
      if ( dLots > _dVolumeMax )
         dLots = _dVolumeMax;
   
      myLogger.logDEBUG( StringFormat( "final/normalized _dLots: %s \r\n", sFmt2dp(dLots) ) );
      return( dLots );
   };




//Dollars must be defined after Ticks and Lots
class PHDollar {
      //<<<Private Attributes>>>
      private:
         double _amt;

      //<<<Public Methods>>>
      public:
                  //Constructors
                  PHDollar::PHDollar( const double amt )
                     { this._amt = amt; };
                  PHDollar::PHDollar( const PHDollar& dlr )    //Copy Constructor
                     { this._amt = dlr._amt; };
                  PHDollar::PHDollar( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHLots& oLots );  //Complex Constructor (previously known as the 'Ticks2ValueCalculator()' function)

         string   PHDollar::toString()
                     //{ return(StringFormat( "$ %.2f", _amt ) ); };
                     const { return( sFmtMny( toNormalizedDouble() ) ); };
         double   PHDollar::toNormalizedDouble()
                     const { return( NormalizeDouble( _amt, 2 ) ); };    //This will round to the necessary # digits, but may not *display* them to the desired format!
         void     PHDollar::freeMarginAfterOrder( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES& eOrderType, const PHLots& numLots );
}; //end Class

   //+------------------------------------------------------------------+
   //| PHDollar   Constructor #3 (previously known as the 'Ticks2ValueCalculator()' function)
   //|
   //| Formula: (Price Move / (Value of a tick in Deposit Currency ) * Value of a tick in Quote Currency ) * Num of Lots
   //| Note:
   //|   - formula uses fractions of a Lot, NOT units!
   //|   - formula uses ticks, not Points.  For an explanation, see http://forum.mql4.com/33975
   //|   - the result may not necessarily equal the sale value, unless you've already factored the spread into the Price Move
   //|
   //| Takes: the Price Move difference (between two Price Levels) in terms of the counter currency, and a Lot size
   //| Returns: Calculates the value of a position
   //|
   //| Why is the Bid/Ask not involved here??  
   //|   a) Because the spread is insignificant?  (not sure, but don't think so)
   //|   b) Because my Stop Loss value will be calculated *after* the sale/slippage has been estabished  (MORE LIKELY ANSWER)
   //| 
   //| Gets called by (called *twice* before opening a trade):
   //|   1. sizePercentRiskModel() - initially to figure out the cost of opening a full (1.0) Lot  (which is typically too much)
   //|   2. openTradeAtMarket()    - 2nd time: after I've figured out how much I can afford to risk, to figure out the cost to take the actual position
   //+------------------------------------------------------------------+
   
   /*
   Ray reckons: PositionValueChange = PriceChangeInPips * MarketInfo( OrderSymbol(), MODE_TICKVALUE) * OrderLots();
   auto_free_cloudbreaker reckons: ( MarketInfo( Symbol(), MODE_TICKVALUE) * Point ) / MarketInfo( Symbol(), MODE_TICKSIZE )
   */
   PHDollar::PHDollar( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHLots& oLots )
   {
      LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function
      string sSymbol = EnumToString( eSymbol);
   
      PHDollar oValueOf1Tick_USD( SymbolInfoDouble( sSymbol, SYMBOL_TRADE_TICK_VALUE ) );
      myLogger.logDEBUG( StringFormat("Num Lots: %s; Stop Loss (in Ticks): %s;  ValueOf1Tick_USD: %s",   oLots.toString(), oTicks_StopLossWidth.toString(), oValueOf1Tick_USD.toString() ) );

      this._amt = ( oTicks_StopLossWidth.toNormalizedDouble() * oValueOf1Tick_USD.toNormalizedDouble() * oLots.toNormalizedDouble() * oLots.getStandardContractSize() );
      myLogger.logINFO(StringFormat("ValueOfPosition (in Deposit Currency/USD): %s",   this.toString() ) );
   
         //OLD/Working[but poor UoM choice]: Money valueInUSD = (dPriceMove / MarketInfo( sSymbol, MODE_TICKSIZE ) ) * MarketInfo( sSymbol, MODE_TICKVALUE ) * dBallparkLots;
         //   double valueInUSD = dPriceMove * (MarketInfo(Symbol(),MODE_TICKVALUE)*Point)/MarketInfo(Symbol(),MODE_TICKSIZE) * (dLots * MarketInfo( Symbol(), MODE_LOTSIZE ) );  incorrect!!!
   
      //return(dValueOfPosition_USD);
   };
   


   //+------------------------------------------------------------------+
   //| PHDollar   freeMarginAfterOrder
   //|
   //+------------------------------------------------------------------+
   void     PHDollar::freeMarginAfterOrder( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES& eOrderType, const PHLots& numLots )
   {
      LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function
   
      string sSymbol = EnumToString( eSymbol);
      
      PHDollar oFreeMarginPriorToTrade( AccountFreeMargin() );
      
      this._amt = AccountFreeMarginCheck( sSymbol, eOrderType, numLots.toNormalizedDouble() );
      int iError = GetLastError();
      if( ( this._amt <= 0) || (iError == 134) )
         myLogger.logERROR( StringFormat( "Free margin is insufficient! (symbol: %s, num lots: %s)", sSymbol, numLots.toString() ) );

      PHDollar oEstPosValue( ( oFreeMarginPriorToTrade.toNormalizedDouble() - this._amt ) * AccountLeverage() );
      PHPercent oAvailPercentMarginAfterTrade( this._amt / oFreeMarginPriorToTrade.toNormalizedDouble(), 2 );
      myLogger.logINFO( StringFormat( "Estimated Position Value: %s (figures not accurate until after order and Slippage taken into account)", oEstPosValue.toString() ) );

      myLogger.logINFO(StringFormat("FYI Margin Required to open one Lot: $ %.2f", MarketInfo(sSymbol, MODE_MARGINREQUIRED)));
      myLogger.logINFO(StringFormat("Testing a %s of %s lots at the appropriate Price determined by the \'AccountFreeMarginCheck()\' function", EnumToString(eOrderType), numLots.toString() ));
      myLogger.logINFO(StringFormat("\tThe \'MarketInfo(MODE_MARGINREQUIRED)\' function states that you will require $ %.2f of Margin to buy one Lot", MarketInfo(sSymbol, MODE_MARGINREQUIRED) ) );
      myLogger.logINFO(StringFormat("\tThe \'AccountFreeMarginCheck\' (%s %s lots of %s) function returns $ %s meaning it must use up $ %.2f of margin [\'Available Margin prior to trade\' minus the \'Estimated free margin after trade\' (from function)]", EnumToString(eOrderType), numLots.toString(), sSymbol, this.toString(), ( oFreeMarginPriorToTrade.toNormalizedDouble() - this.toNormalizedDouble() ) ) );
      myLogger.logINFO(StringFormat("\t\tor put as a percentage, you would still have: %s %% of Available Margin left after the trade", sFmt2dp(oAvailPercentMarginAfterTrade.getFigure() ) ));
      myLogger.logINFO(StringFormat("\t\tThe Account Stop Out Level: %s", sFmtDdp(AccountStopoutLevel())));
   
   };
   




/*
class PHQuote  {
      //<<<Private Attributes>>>
      private:
         PHDecimal _val;

      //<<<Public Methods>>>
      public:
                  PHQuote( const double value, const int precision )    
                     { _val.d_units = value;  _val.i_precision = precision; };
         string   toString()
                     const { return( DoubleToStr( _val.d_units, _val.i_precision ) ); };
         PHTicks  PHQuote::toTicks();
}; //end Class
*/





#ifndef _HANDY

   #define _HANDY

   //------------------------------------------
   //
   // <<<<< HELPER FUNCTIONS >>>>>
   //
   //------------------------------------------
   
   // Format to 'Digits' number of decimal places ('Digits' varies per currency).
   // This will automatically format a JPY (2dp) differently from a USD (4dp).
   string sFmtDdp( const double d )
     {
      return( DoubleToStr( d, Digits ) );     //This will round to the necessary # digits, and *display* them to the desired format!
     }
   
   
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   double dNormD( const double d )
     {
      return( NormalizeDouble( d, Digits ) );    //This will round to the necessary # digits, but may not *display* them to the desired format!
     }
   
   //+------------------------------------------------------------------+
   //| sFmtMny  (2 dp with a $ prefix                                   |
   //+------------------------------------------------------------------+
   string sFmtMny( const double d )
     {
      return(StringFormat( "$ %.2f", d ) );
     }

   //+------------------------------------------------------------------+
   //| sFmtMny  (2 dp with no prefix                                   |
   //+------------------------------------------------------------------+
   string sFmt2dp( double d )
     {
      return(StringFormat( "%.2f", d ) );
     }


      /* //Validate params - saved
      {
         string sLogMsgAddendum = "";
         if ( eSymbol == NULL ) {
            //Asuume Symbol of current market, and convert/enumate
            sSymbol = Symbol();
            PH_FX_PAIRS eVal = -1;
            _eSymbol = StringToEnum( sSymbol, eVal );
            sLogMsgAddendum = "(not supplied... assuming)";
         } else {
            _eSymbol = eSymbol;
            sSymbol = EnumToString( _eSymbol );
         } //end if
      }
      //end - Validate params */
     

#endif 
//+------------------------------------------------------------------+


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
//| A note on why I use DUMMY Constructors (Unitialized/Empty)
//|
//| Reason #1
//| =========
//| At one point I tried to turn this into an Abstract Class - but I couldn't 't get the compiler to recognize this
//| ...so I made the class UNUSUABLE by having only this one Constructor that couldn't take any values  ;o)
//|
//| Reason #2
//| =========
//| Inherited Classes *ARE FORCED* to call one of the Base Classes Constructors.
//| I really struggle trying to construct all the necessary the parameters for a parameterized Constructor in the "limited environment"* provided by the inherited Class' 'Initialization List'.
//| I'd much rather initialize the Base class with DUMMY values...and then set it properly in the "full environment" provided by an inherited Method's normal function.
//|
//| *"limited environment" defined:
//|   1) If I want to call a Base's Constructor, the only way to call it is via the 'Initialization List' within the Method's signature (within the Class defintion).  It cannot be called from within a normal MQL function
//|   2) But if I call a Base's Constructor via the Method's signature, I'm forced to implement the implement the body with {}, again within the Method's signature (within the Class defintion).
//| It seems kinda "all or nothing" - I either call a Super that gets me partially the way there, or I'm forced to abandon the Super, and repeat(copy/paste) all the effort/code in my Child Constructor.  Dumb.
//| It seems the best I can do, is:
//|   a) call a super-simple Base Constructor via the 'Initialization List' within the Method's signature (that sets as much as it can, given the limited knowledge)
//|   b) reference a standard function within the {} body within the Method's signature (within the Class defintion)
//|
//+------------------------------------------------------------------+







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
      
   protected:
      //Protected Attributes
      long              _lUnits;       // The decimal value (Stored as a Long)
      int               _iPrecision;   // Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01
      PH_OBJECT_STATUS  _eStatus;   //I should make this private and only accessible via a "is" method, but Hey (shrug)
      
   public:
         //Constructors (Abstract Class)
                           PHDecimal::PHDecimal(); // Constructor #0 - creates an invalid object! See my notes regarding "DUMMY Constructor #0" below on why I'm doing this...
                           PHDecimal::PHDecimal( const double dInitialUnits, const int iPrecision );  // Constructor #1 - The "real" Constructor

         //Public Methods
                  void     PHDecimal::setValue( const double dInitialUnits, const int iPrecision );
                  void     PHDecimal::unsetValue();

                  void     PHDecimal::add     ( const double dAddUnits );
                  void     PHDecimal::subtract( const double dSubUnits );
                  void     PHDecimal::multiply( const double dMultiplicationUnits );
                  void     PHDecimal::divide  ( const double dDivisionUnits );
                  bool     PHDecimal::compare ( const double dComparitorUnits );
                  bool     PHDecimal::lessThanOrEqualTo ( const PHDecimal& oComparitorUnits ) const;
                  
                  bool     PHDecimal::isValueReadable() const;
                  double   PHDecimal::toNormalizedDouble() const;
                  string   PHDecimal::toString() const 
                           { string sFormatString = StringFormat( "%%.%if", _iPrecision ); return( StringFormat( sFormatString, toNormalizedDouble() ) ); };

   private:
         //Private methods
                  double   PHDecimal::prenormalizeOperand_round( const double dOperand ) const;
                  long     PHDecimal::normalizeAndShiftLeft( const double dOperand ) const;
      
}; //end Class PHDecimal


   //+------------------------------------------------------------------+
   //| PHDecimal - DUMMY Constructor #0 (Unitialized/Empty)
   //|
   //+------------------------------------------------------------------+
   PHDecimal::PHDecimal() 
   {
      this._eStatus    = OBJECT_UNITIALIZED;
      this._lUnits     = NULL;
      this._iPrecision = NULL;
   };  //end Constructor


   //+------------------------------------------------------------------+
   //| PHDecimal - Constructor #1 (Elemental)
   //|
   //| This a skeleton Constructor really.  Why is this so empty? Why does all this Constructor really do is just call the 'setValue()' method?
   //| Answer: Because it's difficult to call Base's Constructors (because it's hard to often *construct* the necessary parameters using the 
   //|   restricted environment provided by the inherited Class' "Initialization List")
   //|
   //| So the Constructor(s) of this Base class AND the Constructor(s) of any inherited class will do any necessary preparation work then call my 'setValue()' with the correct params
   //+------------------------------------------------------------------+
   PHDecimal::PHDecimal( const double dInitialUnits, const int iPrecision ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dUnits: %g, iPrecision: %i } ", dInitialUnits, iPrecision ) );

      setValue( dInitialUnits, iPrecision );
      myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", this._lUnits, this._iPrecision ) );
            
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - SetValue()         [using Atomic Parameters]
   //|
   //| Sets both the 'Units' and 'Precision'
   //|
   //| Called by 
   //|   1. This Classes Constructor 
   //|   2. and when manually changing a value in this Class
   //|   3. By inherited Classes Constructors - I'd much rather initialize the Base class with DUMMY values...and then set it properly in an inherited Method's function.
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::setValue( const double dInitialUnits, const int iPrecision )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dUnits: %g, iPrecision: %i } ", dInitialUnits, iPrecision ) );
      
      if ( iPrecision > _MAX_PRECISION ) {
         unsetValue();
         myLogger.logERROR( StringFormat( "Precision cannot be greater than %i", _MAX_PRECISION ) );
      } else {
         if ( iPrecision < 0 ) {
            unsetValue();
            myLogger.logERROR( "Precision cannot be less than 0" );
         } else {
            this._eStatus    = OBJECT_FULLY_INITIALIZED;
            this._iPrecision = iPrecision;
            this._lUnits     = normalizeAndShiftLeft( dInitialUnits);
         }
      } //end if

      myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", this._lUnits, this._iPrecision ) );
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - UnSetValue()
   //|
   //| Unsets both the Units and Precision
   //| Also called by PHDecimals' Constructor when it detects an invalid percentage (<0 or >100)
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::unsetValue()
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      
      this._eStatus    = OBJECT_UNITIALIZED;
      this._lUnits     = NULL;
      this._iPrecision = NULL;

      myLogger.logINFO( "No params. Object has been unintialized. Values set to NULL" );
   };  //end Constructor


   //+------------------------------------------------------------------+
   //| PHDecimal - isValueReadable()
   //|
   //| A public Method to indicate the object's Status
   //|   >> True  when OBJECT_FULLY_INITIALIZED
   //|   >> False when OBJECT_PARTIALLY_INITIALIZED or OBJECT_UNITIALIZED
   //|
   //| The idea is that you should call this before calling the .toNormalizedDouble() Method.  
   //|   If it returns a false, then simply don't bother (or discard the results)
   //|
   //+------------------------------------------------------------------+
   bool     PHDecimal::isValueReadable() const
   {
      return(  ( this._eStatus == OBJECT_FULLY_INITIALIZED ) ? true : false );
   }





   //+------------------------------------------------------------------+
   //| PHDecimal - Addition()
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::add( const double dAddUnits ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dAddUnits: %g } ", _lUnits, dAddUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         this._lUnits += normalizeAndShiftLeft( dAddUnits);

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   };  //end add()



   //+------------------------------------------------------------------+
   //| PHDecimal - Subtraction()
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::subtract( const double dSubUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dSubUnits: %g } ", _lUnits, dSubUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         this._lUnits += normalizeAndShiftLeft( dSubUnits);

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   }; //end sub()



   //+------------------------------------------------------------------+
   //| PHDecimal - Multiplication()
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::multiply( const double dMultiplicationUnits )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dMultplicationUnits: %g } ", _lUnits, dMultiplicationUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {
      
         int iDigits = StringLen( string( this._lUnits ) );

         if ( ( iDigits > 16 ) && ( dMultiplicationUnits > 1 ) ) {
            myLogger.logERROR( StringFormat( "Potential Overflow detected: %.8g (%i digits) x %.2g) ", this._lUnits, iDigits, dMultiplicationUnits )  );
            unsetValue();

         } else {
            long lNormalizedValue = normalizeAndShiftLeft( dMultiplicationUnits);
            {
               string s1 = string( lNormalizedValue );
               string s2 = string( this._lUnits );
               myLogger.logDEBUG( StringFormat( "lNormalizedValue digits: %i, %s ", StringLen( s1 ), s1 )  );
               myLogger.logDEBUG( StringFormat( "_lUnits: %i, %s", StringLen( s2 ), s2 )  );
            }
            
            // Step #3a: Finally, perform the operation (multiplication) - apply the Operand to the Class' value
            long lOverMultipliedValue = (this._lUnits * lNormalizedValue);
            {
               string s3 = string( lOverMultipliedValue );
            myLogger.logDEBUG( StringFormat( "Step#3a Over-Multiplied Value [long]: %g %s", lOverMultipliedValue, s3 ) );
            }
   
            // Step #3b: Unfortunately, you've not only multiplied the Units, but also the Precision (by 2dp). 
            // So shift the intermediate result right by '_iPrecision' digits
            this._lUnits = (lOverMultipliedValue / (long) MathPow( 10, this._iPrecision ));  //e.g. divide by 100 (for 2dp)
   
            myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
         } //end if "overflow detected"

      } else {
         myLogger.logERROR( "Multiplication cannot be performed on an uninitialized Object!" );
         unsetValue();
         
      }//end if "Object is Fully Initialized"
      
   }; //end multiply()



   //+------------------------------------------------------------------+
   //| PHDecimal - Division()
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::divide( const double dDivisionUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dDivisionUnits: %g } ", _lUnits, dDivisionUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
         // Step #2: "Push"/cast the Operand into a Long, shifted left by '_iPrecision' digits
         long lNormalizedValue = normalizeAndShiftLeft( dDivisionUnits );

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
   //| PHDecimal - Comparison()
   //|
   //| This method is *superior* to attempting to COMPARE two DOUBLE values!
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

         // Step #2: Cast the operand into a PHDecimal *over the same Precision) as this object
         PHDecimal oThat( dComparitorUnits, this._iPrecision );

         // Step #3: Now it's simply a matter of comparing the Long Units (now they have common Precisions)
         if ( this._lUnits == oThat._lUnits )
            isEqual = true;

         myLogger.logINFO( StringFormat( "final { this._lUnits: %g, oThat._lUnits: %i } ", this._lUnits, oThat._lUnits ) );

      } else
         myLogger.logERROR( "Comparison (eq) cannot be performed on an uninitialized Object!" );
      
      return( isEqual );
      
   }; //end comparison()





   //+------------------------------------------------------------------+
   //| PHDecimal - lessThanOrEqualTo()
   //|
   //| 
   //|
   //+------------------------------------------------------------------+
   bool     PHDecimal::lessThanOrEqualTo ( const PHDecimal& oComparitorUnits ) const
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "param { dComparitorUnits: %s } ", oComparitorUnits.toString() ) );
      
      bool isLessThanOrEqualTo = false;
      
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Ensure 'this' and 'that' are of the same Precision
         if ( this._iPrecision != oComparitorUnits._iPrecision ) {
            myLogger.logERROR( "Operations on PHDecimals of differing Precisions not supported yet!" );
         } else {
            isLessThanOrEqualTo = ( this._lUnits <= oComparitorUnits._lUnits ) ? true : false;
         } //end if
      
      } else
         myLogger.logERROR( "Comparison (lte) cannot be performed on an uninitialized Object!" );
      
      return( isLessThanOrEqualTo );

   
   }



   //+------------------------------------------------------------------+
   //| PHDecimal - toNormalizedDouble
   //|
   //| This should be the *only* way to retrieve the value 
   //|  (Other retreival methods must be a wrapper around this one)
   //|
   //|   1. Cast the units as a Double
   //|      I considered performing Cash Rounding on a Long - which appears that it would probably work
   //|      (the result of the divide [ Units / VolumeStep ] would get truncated into an Int or Long...but that forces me to always round DOWN/truncate. If I use Doubles, I get to choose how to round)
   //|      But I now cast early because:
   //|         a) I have to eventually return a Double anyway
   //|         b) The maths of Steps #2 and #3 become easier using Doubles
   //|
   //|   2. Shift the value to the right (by 'Precision' number of digits)
   //|
   //+------------------------------------------------------------------+
   double   PHDecimal::toNormalizedDouble() const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dUnits;
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {
      
         // Step #1. Cast the units as a Double
         double dUnits_Long = (double) this._lUnits;

         // Step #2 - Shift the value to the right (by 'Precision' number of digits)
         double dPrecisionMultiples = MathPow( 10, -this._iPrecision );  //Note the *minus power* e.g. returns 0.01 (for 2dp) which will result in a number format: "n.nn"
         dUnits = dUnits_Long * dPrecisionMultiples;
         
         myLogger.logINFO( StringFormat( "final { dUnits: %g, _iPrecision: %i } ", dUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "No value to return on an uninitialized Object!" );
         dUnits = NULL;
      }

      return( dUnits );
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
   //| *Must* be be applied to *every* incoming double passed in as a parameter
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
   //| PHDecimal   normalizeAndShiftLeft()
   //|
   //| Normalize
   //| =========
   //| Determine the number in multiples of the least significant digit
   //|   e.g. for 2dp, the number must be in multiples of 0.01
   //|
   //| This instance will >>>Round to the nearest digit<<<   e.g. 0.238 becomes 0.24 (for 2dp).  
   //|   Alternative methods might StepUp (0.232 forced up to 0.24) or StepDown/Truncate (0.238 forced down to 0.23)
   //|
   //| *Must* be be applied to *every* incoming double passed in as a parameter
   //|
   //| Shift Left
   //| ==========
   //| Push the double into its Long form by shifting the number left by Precision digits
   //|
   //+------------------------------------------------------------------+
   long PHDecimal::normalizeAndShiftLeft( const double dOperand ) const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dPrecisionMultiples = MathPow( 10, -this._iPrecision );  //Note the minus power e.g. 10^-2.  This will return my 'multiples of least significant digit' e.g. 0.01
      double dNormalizedOperand = MathRound( dOperand / dPrecisionMultiples ) * dPrecisionMultiples; //actually performs the normalization.  e.g. 0.238 becomes 0.24 (for 2dp)
      myLogger.logDEBUG( StringFormat( "Step #1: Pre-NormalizedOperand - Rounded [double]: %g ", dNormalizedOperand ) );

      long lNumberInLongFormat = (long) ( dNormalizedOperand * MathPow( 10, this._iPrecision ));   //e.g. multiply by 1000 (for 3dp) i.e. shift the number left by 3 digits
      myLogger.logDEBUG( StringFormat( "Step #2 (final) NormalizedValue [long]: %i ", lNumberInLongFormat ) );

      return( lNumberInLongFormat );   
   };


//=====================================================================================================================================================================================================


//+------------------------------------------------------------------+
//| PHCurrDecimal
//|
//| An extension of my PHDecimal Class.  It adds:
//|   >> Cash Rounding
//|   >> Market Currency Symbol
//|
//+------------------------------------------------------------------+
class PHCurrDecimal : public PHDecimal {

   //<<< Attributes >>>
   protected:
         PH_FX_PAIRS       _eSymbol;
         string            _sSymbol;   //I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
         double            _dCashRoundingStep; // The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25

//       //Inherited Attributes from PHDecimal
//       PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
//       long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
//       int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

   //<<< Methods >>>
   public:
         //Constructors
                           PHCurrDecimal::PHCurrDecimal() : _eSymbol( NULL), _sSymbol( NULL), _dCashRoundingStep( NULL), PHDecimal() { } ;   //Construct an UNINITIALIZED object
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const PH_FX_PAIRS eSymbol );  // Constructor #1 - The "real" Constructor
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol );  // Constructor #2 - Constructor for tesing Cash Rounding

         //Public Methods
         void              PHCurrDecimal::setValue( const double dInitialUnits, const PH_FX_PAIRS eSymbol );
         double            PHCurrDecimal::toNormalizedDouble() const;    // Override PHDecimal::toNormalizedDouble()

}; //end Class PHCurrDecimal


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - DUMMY Constructor #0 (Unitialized/Empty)
   //|
   //+------------------------------------------------------------------+
   // (Defined in Class Signature above)
   // 1. Call PHDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED
   // 2. Set eSymbol and sSymbol to NULL
   // 3. Set Cash Rounding to NULL


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - Constructor #1 (Elemental)
   //|
   //| This a skeleton Constructor really.  Why is this so empty? Why does all this Constructor really do is just call the 'setValue()' method?
   //| Answer: Because it's difficult to call Base's Constructors (because it's hard to often *construct* the necessary parameters using the 
   //|   restricted environment provided by the inherited Class' "Initialization List")
   //|
   //| So the Constructor(s) of this Base class AND the Constructor(s) of any inherited class will do any necessary preparation work then call my 'setValue()' with the correct params
   //+------------------------------------------------------------------+
   PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const PH_FX_PAIRS eSymbol ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dInitialUnits: %g, eSymbol: %s } ", dInitialUnits, eSymbol ) );

      setValue( dInitialUnits, eSymbol );
      myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %g, _dCashRoundingStep: %g }", this.toString(), this._sSymbol, this._iPrecision, this._dCashRoundingStep ) );
            
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHCurrDecimal - Constructor #2 (Elemental)
   //|
   //| I needed a way to test the Cash Rounding functionality
   //+------------------------------------------------------------------+
   PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol )  // Constructor #2 - Constructor for tesing Cash Rounding
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      setValue( dInitialUnits, eSymbol );
      this._iPrecision = iPrecision;
      this._dCashRoundingStep = dCashRoundingStep;
      
      myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %g, _dCashRoundingStep: %g }", this.toString(), this._sSymbol, this._iPrecision, this._dCashRoundingStep ) );
   }


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - SetValue()   [using Atomic Parameters]
   //|
   //| Sets Value, Symbol, Precision and Cash Rounding (a.k.a. Tick Size) - actually, given a Symbol, I can automatically derive the 'Precision' and 'Cash Rounding' from it
   //| So the Constructors are quite different from PHDecimal - All I need to be supplied is: 'Value' and 'Symbol' 
   //|
   //| Cash Rounding
   //| =============
   //| Typically, the lowest physical denomination of a currency is the same value as Point (i.e. Precision represented as a decimal) e.g. 0.01
   //| However, in some markets (not even currencies), Cash Rounding needs to be applied. 
   //|   e.g. The Precision might be 0.01 but the actual lowest physical denomination of currency is 0.25
   //| Using the above example I'll need to round to multiples of 0.25 rather than 0.01
   //|
   //| [TBC]Called by 
   //| [TBC]  1. This Classes Constructor 
   //| [TBC]  2. and when manually changing a value in this Class
   //| [TBC]  3. By inherited Classes Constructors - I'd much rather initialize the Base class with DUMMY values...and then set it properly in an inherited Method's function.
   //|
   //+------------------------------------------------------------------+
   void PHCurrDecimal::setValue( const double dInitialUnits, const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params { value: %g, sSymbol: %s }", dInitialUnits, EnumToString( eSymbol ) ) );

      //Set my mandatory Class Attributes
      this._eSymbol = eSymbol;
      this._sSymbol = EnumToString( eSymbol );

      //Determine the TickSize for the market - will get set as the 'Cash Rounding' Attribute
      this._dCashRoundingStep = SymbolInfoDouble( this._sSymbol, SYMBOL_TRADE_TICK_SIZE );  //e.g. 0.0001  (sometimes, 0.25 - even though the Point size is 0.01!)

      // Prepare the PHDecimal object 
      {
         //Determine the Precision for the market (typially either 3DPs or 5DPs)
         int iPrecision = (int) SymbolInfoInteger( this._sSymbol, SYMBOL_DIGITS );
         
         PHDecimal::setValue( dInitialUnits, iPrecision );

         myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %.8g, _dCashRoundingStep: %.8g }", this.toString(), this._sSymbol, iPrecision, this._dCashRoundingStep ) );
      } // end of PHDecimal prep

   }; //end PHTicks:: Constructor




   //+------------------------------------------------------------------+
   //| PHCurrDecimal - toNormalizedDouble()
   //|
   //| This should be the *only* way to retrieve the value 
   //|  (Other retreival methods must be a wrapper around this one)
   //|
   //|   1. Call the PHDecimal::toNormalizedDouble() to:
   //|      a. Cast the units as a Double
   //|         I considered performing Cash Rounding on a Long - which appears that it would probably work
   //|         (the result of the divide [ Units / VolumeStep ] would get truncated into an Int or Long...but that forces me to always round DOWN/truncate. If I use Doubles, I get to choose how to round)
   //|         But I now cast early because:
   //|            a) I have to eventually return a Double anyway
   //|            b) The maths of Steps #2 and #3 become easier using Doubles
   //|
   //|      b. Shift the value to the right (by 'Precision' number of digits)
   //|
   //|   2. Perform Cash Rounding on the Double value
   //|      When the lowest denomination (Tick Value) is the same as the Point Value this initially appears to be an unnecessary step e.g. 1234 ÷ 1 (the equiv of 12.34 ÷ 0.01) 
   //|      But this step becomes necessary when they are different (as in metals) where I must return multiples in a different Step Size e.g. 1234 ÷ 25 (the equiv of 12.34 ÷ 0.25)
   //|
   //+------------------------------------------------------------------+
   double   PHCurrDecimal::toNormalizedDouble() const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dUnits;
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {
      
         // Step #1. Cast the units as a Double and Shift the value to the right (by 'Precision' number of digits)
         dUnits = PHDecimal::toNormalizedDouble();
         myLogger.logDEBUG( StringFormat( "Shifted Right (But not yet Cash-Rounded) { dUnits: %g, _iPrecision: %i } ", dUnits, _iPrecision ) );
         
         // Step #2 - Cash Rounding
            //His Code [https://mql4tradingautomation.com/mql4-calculate-position-size/]:     dLotSize = MathRound( LotSize / MarketInfo( Symbol(), MODE_LOTSTEP ) ) * MarketInfo( Symbol() , MODE_LOTSTEP );
         dUnits = MathRound( dUnits / _dCashRoundingStep ) * _dCashRoundingStep;

         myLogger.logINFO( StringFormat( "final (Cash Rounded) { dUnits: %g, _iPrecision: %i } ", dUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "No value to return on an uninitialized Object!" );
         dUnits = NULL;
      }

      return( dUnits );
   };  //end toNormalizedDouble()










//=====================================================================================================================================================================================================


//+------------------------------------------------------------------+
//| PHPercent
//|
//| Admittedly, a rather simple numerical object
//| But one who's rules mean that it can only exist between 1 and 100
//| So it kinda has that logic 'baked in' and >>>you don't have to worry about it<<<
//|
//+------------------------------------------------------------------+
class PHPercent : public PHDecimal {

      //Attributes
//       //Inherited Attributes from PHDecimal
//       PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
//       long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
//       int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

      //Public Methods
      public:
                  PHPercent::PHPercent( const double dFigure, const int iPrecision ) : PHDecimal() { validateAndSetValue( dFigure, iPrecision ); } ;   //Supply a decimal between 0.0 and 100.0

//                  PHPercent::setPercent( const double dPercent );

         double   PHPercent::getFigure()  const { return this.toNormalizedDouble(); };            //Returns a value between 0    and 100
         double   PHPercent::getPercent() const { return PHDecimal::toNormalizedDouble()/100; };  //Returns a value between 0.00 and   1.00
         
      //Protected Methods
     protected:
         void     PHPercent::validateAndSetValue( double dFigure, const int iPrecision );

}; //end Class PHPercent

   //+------------------------------------------------------------------+
   //| PHPercent - validateFigure
   //|
   //| I would usually perform validation within the Constructor, but since this has been subclassed from the PHDecimal class,
   //|   I only get to choose which Base class' Constructor gets called!
   //|
   //| Aside: Watch how the Constructor declaration (in the class) calls the Base's (default) Constructor in the 'Initialization List' (which honestly, in this particular case, does next-to-nothing)
   //|        Then, basically, I call the '.validateAndSetFigure()' Method to do all the *real* work
   //|
   //| So I'll allow the Base class Constructor to set a basically 'undefined/uninitialized' object
   //| and then (in this Method) come along, perform validation, and either 
   //|   a) Warn the user (again, allowing the values set by the Base Constructor to stand as-is)
   //|   b) Override the Value with 100% if set out-of-bounds (i.e. <0 or >100)
   //|   c) allow the values set by the Base Constructor to stand as-is
   //|
   //+------------------------------------------------------------------+
   void PHPercent::validateAndSetValue( double dFigure, const int iPrecision )
   {   
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      // Call Base Class' .setValue() Method 
      // Note that 'Cash Rounding' not applicable for Percentages
      PHDecimal::setValue( dFigure, iPrecision );
      
      if ( (dFigure > 0) && (dFigure < 1) )
         myLogger.logWARN( StringFormat( "Percentages can be set between 0 and 100. If you meant to set a percentage between 0%% and 1%% then fine. Otherwise, if you meant %g%%, set it as %g instead", (dFigure*100), (dFigure*100) ) );
      
      if ( ( dFigure < 0 ) || ( dFigure > 100 ) ) {
         myLogger.logWARN( StringFormat( "params passed { value: %g } is out of bounds - Object is invalid.", dFigure ) );
         this.unsetValue();
      } //end if

   } //end method









//   PHTicks adds no new Attributes, but it does add Tick-specific methods (such as the "CalcStopLossWidth_10dATRx3()" function)


//=====================================================================================================================================================================================================

class PHTicks : public PHCurrDecimal
{

      //Attributes
//       //Inherited Attributes from PHDecimal
//       PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
//       long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
//       int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

//       //Inherited Attributes from PHCurrDecimal
//       PH_FX_PAIRS       _eSymbol;           // (Protected)
//       string            _sSymbol;           // (Protected) I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
//       double            _dCashRoundingStep; // (Protected) The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25

   
//       PHDollar    *_DollarArray[];  //For manually-created PHDollars - Necessary to use Pointers - needed for loop and Delete()
         PHTicks     *_TicksArray[];    //For manually-created PHTicks - Necessary to use Pointers - needed for loop and Delete()


      //<<<Private Methods>>>
      private:
//       void        PHTicks::addToDollarArray( PHDollar &oDollar );
         void        PHTicks::addToTicksArray(  PHTicks  &oTick );

      //<<<Public Methods>>>
      public:
      
                     //Constructors
                        PHTicks::PHTicks() : PHCurrDecimal() {}; // Constructor #0 - creates an invalid object! See my notes regarding "DUMMY Constructor #0" below on why I'm doing this...
                        PHTicks::PHTicks( const double dTicks, const PH_FX_PAIRS eSymbol );   //Constructor #1 (Elemental)

//                     PHTicks::PHTicks( const PH_FX_PAIRS eSymbol );                       //Constructor #2 - Previously known as the "dCalcStopLossWidth_10dATRx3()" function
//                     PHTicks::PHTicks( const PHTicks& that );                             //Constructor #3 (Copy Constructor)

                     PHTicks::~PHTicks();
         void        PHTicks::calcStopLossWidth_10dATRx3( const PH_FX_PAIRS eSymbol ) ;
         
/* temp removed
         PHDollar PHTicks::tickValueDollarsPerUnit();
         PHDollar PHTicks::tickValueDollarsPerStdContract();
         PHDollar PHTicks::tickValueDollarsForGivenNumLots( PHLots &oLots );

         //This is now supplied by the PHDecimal inherited class...
         string      PHTicks::toString()
                     const { return( sFmtDdp( toNormalizedDouble() ) ); };
*/


}; //end Class


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - DUMMY Constructor #0 (Unitialized/Empty)
   //|
   //+------------------------------------------------------------------+
   // (Defined in Class Signature above)
   // 1. Call PHCurrDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED
   // 
   // There are no new Attributes


   //+------------------------------------------------------------------+
   //| PHTicks - DUMMY Constructor #0 (Unitialized/Empty)
   //|
   //| Reason #2
   //| =========
   //| Inherited Classes *ARE FORCED* to call one of the Base Classes Constructors.
   //| I really struggle trying to construct all the necessary the parameters for a parameterized Constructor in the "limited environment"* provided by the inherited Class' 'Initialization List'.
   //| I'd much rather initialize the Base class with DUMMY values...and then set it properly in the "full environment" provided by an inherited Method's normal function.
   //|
   //| *"limited environment" defined:
   //|   1) If I want to call a Base's Constructor, the only way to call it is via the 'Initialization List' within the Method's signature (within the Class defintion).  It cannot be called from within a normal MQL function
   //|   2) But if I call a Base's Constructor via the Method's signature, I'm forced to implement the implement the body with {}, again within the Method's signature (within the Class defintion).
   //| It seems kinda "all or nothing" - I either call a Super that gets me partially the way there, or I'm forced to abandon the Super, and repeat(copy/paste) all the effort/code in my Child Constructor.  Dumb.
   //| It seems the best I can do, is:
   //|   a) call a super-simple Base Constructor via the 'Initialization List' within the Method's signature (that sets as much as it can, given the limited knowledge)
   //|   b) reference a standard function within the {} body within the Method's signature (within the Class defintion)
   //|
   //+------------------------------------------------------------------+
/* Disabled - The Attributes get set in the definition (implementation) of the Constructor above
   PHTicks::PHTicks() 
   {
      this._eSymbol    = NULL;
      this._sSymbol    = "";
   };  //end Constructor
*/

   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #1 (Elemental)
   //|
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structure is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const double dTicks, const PH_FX_PAIRS eSymbol ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { value: %s, sSymbol: %s }", sFmtDdp(dTicks), EnumToString( eSymbol ) ) );

      //Set my mandatory Class Attributes
      setValue( dTicks, eSymbol );    
     
   }; //end PHTicks:: Constructor


/*

   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #2 (Copy Object)
   //|
   //| Copies the Tick Value and Symbol over
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structre is sufficient)
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

   }; //end PHTicks:: Constructor
*/


   //+------------------------------------------------------------------+
   //| PHTicks - calcStopLossWidth_10dATRx3() (Ten-Day Average Daily True Range x 3)
   //|
   //| It's designed to be used rather like a Constructor. It doesn't take a Tick value - since it will calculate one itself.
   //|   e.g. >      PHTicks ticks_ADTRx10dayCCPriceMoveWidth();                                //Declare an empty/uninitialized object
   //|        >      ticks_ADTRx10dayCCPriceMoveWidth.calcStopLossWidth_10dATRx3( eSymbol );    //Now populate the object with a self-derived StopLoss Width
   //|        >      sResult = ticks_ADTRx10dayCCPriceMoveWidth.toString();
   //|
   //| Notes:
   //|   >> This is the *width* of the move allowed, which is very different from the absolute 'StopLoss Price Level' (which gets set at a later step)
   //|   >> Note that the StopLoss Width doesn't take the spread into account per se.  That happens by choosing to subtracting it (for a long) from the Ask (not included), or Bid (included) price later.
   //|   >> Returns a value in UoM: Ticks. 
   //|
   //|   >> This particular algorithm uses the ADTR (or rather, multiples of the ADTR). Alternatives algorithms exist (such as MAE)
   //|   >> (Not Applicable, at the moment): Even though a Constrctor, it ignores the Object Arrays - the initialization that occurs in the Class structre is sufficient
   //|
   //| Gets called by:
   //|   a) early during the 'OpenTradeAtMarket()' function to determine the risk (a Price Width)
   //|   b) then again by the 'dCalcStopLossPrice_10dATRx3()' function to re-calculate the absolute StopLoss level (a Price Level)
   //|
   //| Calls:
   //|   -
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structre is sufficient)
   //+------------------------------------------------------------------+
   void PHTicks::calcStopLossWidth_10dATRx3( const PH_FX_PAIRS eSymbol ) 
   {
   
      LLP(LOG_INFO)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

      myLogger.logDEBUG( StringFormat( "param(s) (Constructor #3) { eSymbol: %s }", eSymbol ) );

      // Set my mandatory Class Attributes
      //   In this case, all I've actually been given is the Symbol at this stage.  But I can work out the 'TickSize' and 'Precision' from that.
      //   For now, I'll set a dummy value for Ticks/Price - but by the end of the method, I'll have calculated the Tick/Price Move Width and set it at the end of the method
      setValue( 1, eSymbol );    //Ticks = 1 (DUMMY VALUE - I will re-set once I have the correct value later)

      // Override Object Status with 'Partially Initialized'.  This will prevent it from >>>returning any bad values<<< (specifically via ".toNormalizedDouble()'. 
      // I'll set it to fully initialized when I've set the correct Ticks value
      this._eStatus = OBJECT_PARTIALLY_INITIALIZED;
     
   
      // Calculate the Average Daily True Range on Daily Bars, for a given symbol/period  (x periods back, starting from yesterday)
      // WARNING: I'm using the *Terminal's* Daily periods (not mine)..but who cares for an ADTR, right?!
         HideTestIndicators(true);
   
//          <<<Code to prove the ADTR is working>>>
//         int stPer = 70;
//   
//            double dADTR_d1 = iATR( sSymbol, PERIOD_D1, 1, stPer );
//            double dADTR_d2 = iATR( sSymbol, PERIOD_D1, 2, stPer );
//            double dADTR_d3 = iATR( sSymbol, PERIOD_D1, 3, stPer );
//   
//         datetime Days[];
//         datetime dtDy;
//         string sDy;
//         double High[],Low[];
//         double low, high, diff;
//   
//         ArraySetAsSeries(Days,true);
//         ArraySetAsSeries(Low,true);
//         ArraySetAsSeries(High,true);
//   
//         CopyTime(sSymbol,PERIOD_D1,stPer,3,Days);
//         CopyLow(sSymbol,PERIOD_D1,stPer,3,Low);
//         CopyHigh(sSymbol,PERIOD_D1,stPer,3,High);
//   
//         for(int i = 0; i < 3; i++) {
//            dtDy = Days[i];
//            sDy = TimeToStr( dtDy, TIME_DATE||TIME_SECONDS);
//            high = High[i];
//            low = Low[i];
//            diff = high-low;
//               DebugBreak();
//            }
//   
//          //Result
//          for example on May 04, 2020, the EURUSD (Daily Bars) Opening Price gapped down from May 03's Close:
//            The simple difference between the High and Low on this date was = 0.007870  0.0078699999999998
//            However, the correct ADTR was to take the difference between May 03's Close and May 04's Low = 1.09802 - 1.08956 = 0.00846
//            The iADTR reported it correctly (with the gap)
   
      
      ENUM_TIMEFRAMES ePeriod = PERIOD_D1;
   
      myLogger.logDEBUG( StringFormat( "Constants: 10dATRx3 Averaging Period: %i of %s;  10dATRx3 Multiplier: %f \r\n", _SL10dATRx3_iATRPeriod, EnumToString(ePeriod), _SL10dATRx3_dATRMultiplier ) );
      
      int iPrecision = this._iPrecision;
   
      // Step #1 ("Price Width") - a simple ADTR
      // Begin by calculating the ADTR for a (10 x Day) period for my Market/Symbol.  Declare a new Tick Object of the resultant "price width"
      PHTicks Ticks_ADTRx10dayCCPriceMoveWidth( iATR( this._sSymbol, ePeriod, _SL10dATRx3_iATRPeriod, _YESTERDAY), _eSymbol );    // e.g. something like  "0.009339"
      
      myLogger.logDEBUG( StringFormat( "ATR (Period: %i): %s",    _SL10dATRx3_iATRPeriod, Ticks_ADTRx10dayCCPriceMoveWidth.toString() ) );
      HideTestIndicators(false);
   
      // Step #2 ("Price Width") - The ADTR multiplied by a arbitary factor
      // Given the ADTR, now calculate the Stop Loss Width (as a multiple of the ADTR). UoM is a width in terms of the Country Currency's price
      Ticks_ADTRx10dayCCPriceMoveWidth.multiply( _SL10dATRx3_dATRMultiplier );     // e.g. 0.009339 x 2.9 = 0.02708

      // Now I've calculated the Ticks value fully, I can set the value in my Class' Attribute
      // This will also set the Object Status with 'Fully Initialized'   
      setValue( Ticks_ADTRx10dayCCPriceMoveWidth.toNormalizedDouble(), eSymbol );


      myLogger.logINFO( StringFormat( "RESULT-> StopLoss Width (in Counter Currency Price): %s \r\n", this.toString() ) );
     


   }; //end "calcStopLossWidth_10dATRx3()" function  (Ten-Day Average Daily True Range x 3)

   

   //+------------------------------------------------------------------+
   //| PHTicks - Destructor
   //|
   //+------------------------------------------------------------------+
   PHTicks::~PHTicks() {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logDEBUG( "Destructor" );

      int   iObjDelCount = 0;
      
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
   
   

   
   



//=====================================================================================================================================================================================================

// PHLots adds new Attributes:  
//    >> Minimum Lot Size (typically 0.01)
//    >> Maximum Lot Size (typically 50.0)
//    >> Lot Step Size (typically 0.01)
//    >> Standard Contract Size (typically 100,000)

// PHLots performs a validation step before setting its attributes (similar to PHPercent)

// PHLots must be defined after PHTicks  (I use PHTicks in the methods)

// I use Cash Rounding to ensure that only multiple of Lot size (minimum of 0.01, in multiles of 0.01 and a maximum of 50) are returned.
// Lots may be temporarily breach those rules within this class (while being calculated, for example) but ultimately must comply to the above rules

class PHLots : PHCurrDecimal {

      //Attributes
//       //Inherited Attributes from PHDecimal
//       PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
//       long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
//       int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

//       //Inherited Attributes from PHCurrDecimal
//       PH_FX_PAIRS       _eSymbol;           // (Protected)
//       string            _sSymbol;           // (Protected) I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
//       double            _dCashRoundingStep; // (Protected) The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25

      //<<<Private Attributes>>>
      private:
         //Additional Attributes within PHTicks
//         double      _dVolumeMin, _dVolumeStep, _dVolumeMax, _dStandardContractSize;
         PHDecimal        _volumeMin_Decimal, _volumeStep_Decimal, _volumeMax_Decimal, _standardContractSize_Decimal;

   


      //<<<Public Methods>>>
      public:
                  //Constructors
                  PHLots::PHLots() : PHCurrDecimal() { };  //Construct an UNINITIALIZED object
                  PHLots::PHLots( const double dLots, const PH_FX_PAIRS eSymbol );
                  PHLots::PHLots( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHPercent& oPercentageOfEquityToRisk );

         void     PHLots::commonConstructor( const PH_FX_PAIRS eSymbol );

/* old way...
         double   PHLots::getVolumeMin()            const { return _dVolumeMin; };
         double   PHLots::getVolumeMax()            const { return _dVolumeMax; };
         double   PHLots::getVolumeStep()           const { return _dVolumeStep; };
         double   PHLots::getStandardContractSize() const { return _StandardContractSize; };
*/

         const string PHLots::toString()
                     const { return( sFmt2dp( toNormalizedDouble() ) ); };
         double   PHLots::toNormalizedDouble() const;   //Override/add to PHCurrDecimal's .toNormalizedDouble()  [Max Lot Size < 50!]


      //<<<Private Methods>>>
      private:
         void     PHLots::commonConstructor( const string sSymbol );

}; //end Class


   //+------------------------------------------------------------------+
   //| PHLots - Common Constructor a.k.a Constructor #0 (Common/Environment (No Params))
   //|
   //+------------------------------------------------------------------+
   void  PHLots::commonConstructor( const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      //Set my mandatory Class Attributes
      {
/* old way...
         //--- double value output in a compact format
         this._dVolumeMin = SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MIN );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MIN = %g (minimal volume for a deal)", _dVolumeMin ) );
      
         //--- double value output in a compact format
         this._dVolumeStep = SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_STEP );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_STEP = %g (minimal volume change step)", _dVolumeStep ) );
   
         //--- double value output in a compact format
         this._dVolumeMax = SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MAX );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MAX = %g (maximal volume for a deal)", _dVolumeMax ) );
         
         this._dStandardContractSize = SymbolInfoDouble( _sSymbol, SYMBOL_TRADE_CONTRACT_SIZE );
         myLogger.logDEBUG( StringFormat( "SYMBOL_TRADE_CONTRACT_SIZE = %f", _dStandardContractSize ) );
*/

         //Grab the Precision for the current object - and set these objects to the same Precision. It will make the mathematical operation far, far easier to deal with
         int iPrecision = this._iPrecision;
         
         _volumeMin_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MIN ), iPrecision );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MIN = %s (minimal volume for a deal)", _volumeMin_Decimal.toString() ) );

         _volumeMax_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MAX ), iPrecision );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MAX = %s (maximum volume for a deal)", _volumeMax_Decimal.toString() ) );

         _volumeMin_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_STEP ), iPrecision );
         myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_STEP = %s (deal volume increase step size)", _volumeStep_Decimal.toString() ) );

         _volumeMin_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_TRADE_CONTRACT_SIZE ), iPrecision );
         myLogger.logDEBUG( StringFormat( "SYMBOL_TRADE_CONTRACT_SIZE = %s (numner of Lots/units to a standard contract)", _standardContractSize_Decimal.toString() ) );

      }
      
   };



   //+------------------------------------------------------------------+
   //| PHLots - Constructor #1 (Elemental)
   //|
   //+------------------------------------------------------------------+
   PHLots::PHLots( const double dLots, const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "passed params { dValue: %f, sSymbol: %s }", dLots, eSymbol ) );
      myLogger.logDEBUG( StringFormat( "Max Lt Size: %s", _volumeMax_Decimal.toString() ) );

      if( this.lessThanOrEqualTo( _volumeMax_Decimal ) ) {
      
         PHLots::commonConstructor( eSymbol );
   
         //Call to Super()
         PHCurrDecimal::setValue( dLots, eSymbol );
   
      } else {
         myLogger.logERROR( StringFormat( "Attempt to set Lots (%g) greater than MAX_LOT_SIZE (%s)", _volumeMax_Decimal.toString() ) );
         unsetValue();
      }


   }; //end PHLots:: Constructor





   //+------------------------------------------------------------------+
   //| PHLots - toNormalizedDouble()
   //|
   //| This should be the *only* way to retrieve the value 
   //|  (Other retreival methods must be a wrapper around this one)
   //|
   //|   1. Call the PHDecimal::toNormalizedDouble() to:
   //|      a. Cast the units as a Double
   //|         I considered performing Cash Rounding on a Long - which appears that it would probably work
   //|         (the result of the divide [ Units / VolumeStep ] would get truncated into an Int or Long...but that forces me to always round DOWN/truncate. If I use Doubles, I get to choose how to round)
   //|         But I now cast early because:
   //|            a) I have to eventually return a Double anyway
   //|            b) The maths of Steps #2 and #3 become easier using Doubles
   //|
   //|      b. Shift the value to the right (by 'Precision' number of digits)
   //|
   //|   2. Check the number of units are below
   //|      When the lowest denomination (Tick Value) is the same as the Point Value this initially appears to be an unnecessary step e.g. 1234 ÷ 1 (the equiv of 12.34 ÷ 0.01) 
   //|      But this step becomes necessary when they are different (as in metals) where I must return multiples in a different Step Size e.g. 1234 ÷ 25 (the equiv of 12.34 ÷ 0.25)
   //|
   //+------------------------------------------------------------------+
   double   PHLots::toNormalizedDouble() const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double dUnits;
      if( ( this._eStatus == OBJECT_FULLY_INITIALIZED ) && ( this.lessThanOrEqualTo( _volumeMax_Decimal ) ) ) {
      
         dUnits = PHCurrDecimal::toNormalizedDouble();
         myLogger.logDEBUG( StringFormat( "normalized units (But not yet tested for MAX_SIZE) { dUnits: %g } ", dUnits ) );
         
         myLogger.logINFO( StringFormat( "final (Cash Rounded) { dUnits: %g, _iPrecision: %i } ", dUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "No value to return on an uninitialized Object!" );
         dUnits = NULL;
      }

      return( dUnits );
   };  //end toNormalizedDouble()


/* temp disabled...



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
   
   

*/



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

      this._amt = ( oTicks_StopLossWidth.toNormalizedDouble() * oValueOf1Tick_USD.toNormalizedDouble() * oLots.toNormalizedDouble() /* [TODO]  * oLots.getStandardContractSize() */   );
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


#endif 
//+------------------------------------------------------------------+

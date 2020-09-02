
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



#define PH_CURR_CODE_OFFSET 100
#define PH_CURR_CODE_COUNT  300
enum PH_CURR_CODE
  {
   DUMMY = PH_CURR_CODE_OFFSET,
#include <PHCURRCODES.txt>
  };
  
  
//#define PH_FX_PAIRS_OFFSET 100
#define PH_FX_PAIRS_OFFSET (PH_CURR_CODE_OFFSET + PH_CURR_CODE_COUNT)
#define PH_FX_PAIRS_COUNT  100

enum PH_FX_PAIRS
// Explicitly list "The Majors".  All the rest can be included from an external file. The file has been edited to exclude the seven Majors.
  {
   EURUSD = PH_FX_PAIRS_OFFSET,
   GBPUSD,
   AUDUSD,
   NZDUSD,
   USDJPY,
   USDCHF,
   USDCAD,
#include <PHCURRCODES.txt>
  };



#define PH_ENTRY_REASONS_OFFSET (PH_FX_PAIRS_OFFSET + PH_FX_PAIRS_COUNT)
#define PH_ENTRY_REASONS_COUNT 99

enum PH_ENTRY_REASONS
  {
   ENTRY_not_specified  = PH_ENTRY_REASONS_OFFSET,  //shouldn't ever see this reason
   ENTRY_RANDOMCOINFLIP,
   ENTRY_MA_CROSSOVER,
   ENTRY_ADX,
   ENTRY_PYRAMID,
   ENTRY_ADDTOPOS,
   ENTRY_INTRADAY
  };


#define PH_EXIT_REASONS_OFFSET (PH_ENTRY_REASONS_OFFSET + PH_ENTRY_REASONS_COUNT)
#define PH_EXIT_REASONS_COUNT 100

enum PH_EXIT_REASONS
  {
   EXIT_not_specified  = PH_EXIT_REASONS_OFFSET, //means "The prior setting is probably valid for the exit, and so I don't want you to overwrite the reason"
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


#define PH_TRADE_STATUS_OFFSET (PH_EXIT_REASONS_OFFSET + PH_EXIT_REASONS_COUNT)
#define PH_TRADE_STATUS_COUNT 10

enum PH_TRADE_STATUS
  {
   TRDSTATUS_WAITINGTOOPEN   = PH_TRADE_STATUS_OFFSET,
   TRDSTATUS_ASSUMEDOPEN,
   TRDSTATUS_WAITINGTOCLOSE,
   TRDSTATUS_CLOSED
  };


#define PH_COMPARISON_OPERATOR_OFFSET (PH_TRADE_STATUS_OFFSET + PH_TRADE_STATUS_COUNT)
#define PH_COMPARISON_OPERATOR_COUNT 10

enum PH_COMPARISON_OPERATOR
  {
   gt = PH_COMPARISON_OPERATOR_OFFSET,
   gte,
   lt,
   lte,
   eq,
   ne
  };


#define PH_OBJECT_STATUS_OFFSET (PH_COMPARISON_OPERATOR_OFFSET + PH_COMPARISON_OPERATOR_COUNT)
#define PH_OBJECT_STATUS_COUNT 10

enum PH_OBJECT_STATUS
  {
   OBJECT_UNITIALIZED = PH_OBJECT_STATUS_OFFSET,
   OBJECT_PARTIALLY_INITIALIZED,
   OBJECT_FULLY_INITIALIZED
  };


#define PH_DECIMAL_PRECISION_OFFSET (PH_OBJECT_STATUS_OFFSET + PH_OBJECT_STATUS_COUNT)
#define PH_DECIMAL_PRECISION_COUNT 10

enum PH_DECIMAL_PRECISION
  {
   P_0DP = PH_DECIMAL_PRECISION_OFFSET, P_1DP, P_2DP, P_3DP, P_4DP, P_5DP, P_6DP, P_7DP, P_8DP 
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
   enum eTickerSymbol = EnumToString( eVal = StringToEnum( sVal, eVal ) ) );
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

// <<<Attributes>>>
  
   public:
      //Public Attributes
      
   protected:
      //Protected Attributes
      long              _lUnits;       // The decimal value (Stored as a Long)
      int               _iPrecision;   // Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01
      PH_OBJECT_STATUS  _eStatus;      //I should make this private and only accessible via a "is" method, but Hey (shrug)
      

// <<<Methods>>>
   public:
      //Constructors (Abstract Class)
                            // Constructor #0 [Default] - creates an invalid object! See my notes regarding "DUMMY Constructor #0" below on why I'm doing this...
                           PHDecimal::PHDecimal() : _eStatus( OBJECT_UNITIALIZED ), _lUnits( -1 ), _iPrecision( -1 ) {};
                           // Construct #1 [Parametric] (Regular Constructor)
                           PHDecimal::PHDecimal( const double dInitialUnits, const int iPrecision );  // Constructor #1 - The "real" Constructor

      //Public Methods
                  void     PHDecimal::setValue( const double dInitialUnits, const int iPrecision );
                  void     PHDecimal::unsetValue();

                  void     PHDecimal::add     ( const double     dAddUnits );
                  void     PHDecimal::add     ( const PHDecimal& oAddDecimal );
                  void     PHDecimal::subtract( const double     dSubUnits );
                  void     PHDecimal::subtract( const PHDecimal& oSubDecimal );
                  void     PHDecimal::multiply( const double     dMultiplicationUnits );
                  void     PHDecimal::divide  ( const double     dDivisionUnits );
                  bool     PHDecimal::compare ( const double     dComparitorUnits );
                  bool     PHDecimal::compare ( const PHDecimal& oComparitorUnits );
 /*
                  bool     PHDecimal::gt      ( const PHDecimal& oComparitorUnits ) const;      //greater than
                  bool     PHDecimal::gte     ( const PHDecimal& oComparitorUnits ) const;      //greater than
                  bool     PHDecimal::lt      ( const PHDecimal& oComparitorUnits ) const;      //lessThanOrEqualTo
                  bool     PHDecimal::lte     ( const PHDecimal& oComparitorUnits ) const;      //lessThanOrEqualTo
*/
         bool     PHDecimal::operatorAndOperand( const PH_COMPARISON_OPERATOR eOp, const PHDecimal& oOperand ) const;
                  
                  bool     PHDecimal::isValueReadable() const;
                  double   PHDecimal::toNormalizedDouble() const;
                  string   PHDecimal::toString() const 
                           { string sFormatString = StringFormat( "%%.%if", _iPrecision ); return( StringFormat( sFormatString, toNormalizedDouble() ) ); };
                  string   PHDecimal::objectToString() const
                           { return( StringConcatenate( "PHDecimal={ Units : ", _lUnits, " , Precision: ", _iPrecision, " , Status: ", EnumToString(_eStatus), " }" ) ); };

   private:
      //Private methods
                  double   PHDecimal::prenormalizeOperand_round( const double dOperand ) const;
   protected:
      //Protected methods
                  long     PHDecimal::normalizeAndShiftLeft( const double dOperand ) const;
      
}; //end Class PHDecimal


   //+------------------------------------------------------------------+
   //| PHDecimal - DUMMY Constructor #0 (Unitialized/Empty)
   //|
   //+------------------------------------------------------------------+
/*
   PHDecimal::PHDecimal() 
   {
      this._eStatus    = OBJECT_UNITIALIZED;
      this._lUnits     = -1;
      this._iPrecision = -1;
   };  //end Constructor
*/

   //+------------------------------------------------------------------+
   //| PHDecimal - Constructor #1   [Elemental]
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

      //Call Default Construction (Uninitialize Attributes)
      PHDecimal();
      
      setValue( dInitialUnits, iPrecision );
      myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", this._lUnits, this._iPrecision ) );
            
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHDecimal - SetValue()           [Elemental]
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
      this._lUnits     = -1;
      this._iPrecision = -1;

      myLogger.logINFO( "No params. Object has been unintialized. Values set to NULL" );

   }; //end PHDecimal::unsetValue()


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
   //| PHDecimal - Addition()  [Elemental]
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
   //| PHDecimal - Addition()  [Object]
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::add( const PHDecimal& oAddDecimal ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dAddUnits: %g } ", _lUnits, oAddDecimal._lUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Ensure 'this' and 'that' are of the same Precision
         if ( this._iPrecision != oAddDecimal._iPrecision ) {
            myLogger.logERROR( "Operations on PHDecimals of differing Precisions not supported yet! (The Object has also been invalidated)" );
            unsetValue();
         } else {
            this._lUnits += oAddDecimal._lUnits;
            
         } //end if

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   };  //end add()



   //+------------------------------------------------------------------+
   //| PHDecimal - Subtraction()  [Elemental]
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::subtract( const double dSubUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dSubUnits: %g } ", _lUnits, dSubUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         this._lUnits -= normalizeAndShiftLeft( dSubUnits);

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   }; //end sub()



   //+------------------------------------------------------------------+
   //| PHDecimal - Subtraction()  [Object]
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::subtract( const PHDecimal& oSubDecimal ) 
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "_lUnits: %g; param { dAddUnits: %g } ", _lUnits, oSubDecimal._lUnits ) );

      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

         // Ensure 'this' and 'that' are of the same Precision
         if ( this._iPrecision != oSubDecimal._iPrecision ) {
            myLogger.logERROR( "Operations on PHDecimals of differing Precisions not supported yet! (The Object has also been invalidated)" );
            unsetValue();
         } else {
            this._lUnits -= oSubDecimal._lUnits;
            
         } //end if

         myLogger.logINFO( StringFormat( "final { _lUnits: %g, _iPrecision: %i } ", _lUnits, _iPrecision ) );
      } else {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         this._lUnits = NULL;
      }
   };  //end add()



   //+------------------------------------------------------------------+
   //| PHDecimal - Multiplication()  [Elemental]
   //|
   //+------------------------------------------------------------------+
   void PHDecimal::multiply( const double dMultiplicationUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
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
   
            // Step #3b: Unfortunately, you've not only multiplied the Units, but also the Precision (by e.g. 2dp). 
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
   //| PHDecimal - Division()  [Elemental]
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
         myLogger.logDEBUG( StringFormat( "Step#1&#2 lNormalizedValue [long]: %i ", lNormalizedValue ) );

         // Step #3: Finally, perform the operation (division) - apply the Operand to a temporary variable*
         // Note that the temp variable also needs a double to temporarily handle the decimals
         double dDividedResult = (this._lUnits / (double) lNormalizedValue);     //e.g. 1.666666666...
         myLogger.logDEBUG( StringFormat( "Step#3 dDividedResult [double]: %g ", dDividedResult ) );

         // Step #4: I'll also normalize the result to the correct DPs - rounding as necessary
         double dNormalizedResult = prenormalizeOperand_round( dDividedResult );  //e.g. 1.66667 (@ 5dp)
         myLogger.logDEBUG( StringFormat( "Step#4 dNormalizedResult [double]: %g ", dNormalizedResult ) );
         {
            string s1 = string( dDividedResult );
            string s2 = string( dNormalizedResult );
            int i1 = StringLen( s1 );
            int i2 = StringLen( s2 );
            if ( i2 < i1 )
            myLogger.logWARN( StringFormat( "Possible truncation detected - may result in rounding errors { %s != %s }", s1, s2 ) );
         }

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
   //| PHDecimal - Comparison()  [Elemental]
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
   //| PHDecimal - Comparison()  [Object]
   //|
   //| This method is *superior* to attempting to COMPARE two DOUBLE values!
   //|
   //+------------------------------------------------------------------+
   bool PHDecimal::compare( const PHDecimal& oComparitorUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "param { oComparitorUnits: %s } ", oComparitorUnits.toString() ) );

      bool isEqual = false;
      
      if( this._eStatus == OBJECT_FULLY_INITIALIZED ) {

/* Potential way of comparinng two objects diff precisions...
      xx   // Step #1: pre-normalize the operand (in it's original double form) - in case the next dp pushes the lowest digit value up by one
      xx   double dNormalizedOperand = prenormalizeOperand_round( dComparitorUnits );

      xx   // Step #2: Cast the operand into a PHDecimal *over the same Precision) as this object
      xx   PHDecimal oThat( dComparitorUnits, this._iPrecision );
*/
         // Ensure 'this' and 'that' are of the same Precision
         if ( this._iPrecision != oComparitorUnits._iPrecision ) {
            myLogger.logERROR( "Operations on PHDecimals of differing Precisions not supported yet! (The Object remains valid)" );
         } else {
            // Step #3: Now it's simply a matter of comparing the Long Units (now they have common Precisions)
            isEqual = ( this._lUnits == oComparitorUnits._lUnits ) ? true : false;
            
         } //end if

         myLogger.logINFO( StringFormat( "final { this._lUnits: %g, oThat._lUnits: %i } ", this._lUnits, oComparitorUnits._lUnits ) );

      } else
         myLogger.logERROR( "Comparison (eq) cannot be performed on an uninitialized Object!" );
      
      return( isEqual );
      
   }; //end comparison()




   //+------------------------------------------------------------------+
   //| PHDecimal - operatorAndOperand()
   //|
   //| 
   //|
   //+------------------------------------------------------------------+
   bool     PHDecimal::operatorAndOperand( const PH_COMPARISON_OPERATOR eOp, const PHDecimal& oOperand ) const
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "param { dComparitorUnits: %s } ", oOperand.toString() ) );
      
      bool isConditionSatisfied = false;

      if ( this.isValueReadable() && oOperand.isValueReadable() ) {
         //both objects are fully initialized
         
         if ( this._iPrecision != oOperand._iPrecision ) {
            myLogger.logERROR( "Operations on PHDecimals of differing Precisions not supported yet! (The Object remains valid)" );
         } else {
            //both objects are of the same precision - we can proceed with the comparison
            switch (eOp)
            {
               case gt : isConditionSatisfied = ( this._lUnits  > oOperand._lUnits ) ? true : false; break;
               case lt : isConditionSatisfied = ( this._lUnits  < oOperand._lUnits ) ? true : false; break;
               case gte: isConditionSatisfied = ( this._lUnits >= oOperand._lUnits ) ? true : false; break;
               case lte: isConditionSatisfied = ( this._lUnits <= oOperand._lUnits ) ? true : false; break;
               case eq : isConditionSatisfied = ( this._lUnits == oOperand._lUnits ) ? true : false; break;
               case ne : isConditionSatisfied = ( this._lUnits != oOperand._lUnits ) ? true : false; break;
            
            } //end switch

         }; //end if
      
      } else {
         //one of the objects is not fully initialized
         myLogger.logERROR( "Comparisons cannot be performed on an uninitialized (nor partially initialized) Object!" );
      }; //end if
     
      return( isConditionSatisfied );
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
//| PHPercent    [a subclass of PHDecimal]
//|
//| Admittedly, a rather simple numerical object 
//|
//| But one who's rules mean that it can only exist between 1 and 100
//| So it kinda has that logic 'baked in' and >>>you don't have to worry about it<<<
//|
//+------------------------------------------------------------------+
#define _DEFAULT_PERCENTAGE_PRECISION 2

class PHPercent : public PHDecimal 
{
/*    //<<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

*/

      //<<<Public Methods>>>
      public:
         //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHDecimal's Default Construct
                           PHPercent::PHPercent() {};

                           // Parametric Constructor #1 [Elemental] (Regular Constructor) 
                           // Supply 'Units' (between 0.0 and 100.0) and 'Precision' (defaults to 2).  It's basically a PHDecimal ...with validation rules.
                           PHPercent::PHPercent( const double dFigure, const int iPrecision = _DEFAULT_PERCENTAGE_PRECISION );

         void     PHPercent::setValue(    double dFigure, const int iPrecision = _DEFAULT_PERCENTAGE_PRECISION );
         double   PHPercent::getFigure()  const { return this.toNormalizedDouble(); };            //Returns a value between 0    and 100
         string   PHPercent::toString()   const { return StringConcatenate( sFmtDdp( this.toNormalizedDouble(), this._iPrecision ), "%" ); };  //Returns a string value between 0 and 100, with a "%" suffix
         double   PHPercent::getPercent() const { return PHDecimal::toNormalizedDouble()/100; };  //Returns a value between 0.00 and   1.00





         
      //<<<Protected Methods>>>
     protected:

}; //end Class PHPercent

   //+------------------------------------------------------------------+
   //| PHPercent - Parametric Constructor #1 [Elemental]
   //|
   //| This a skeleton Constructor really.  Why is this so empty? Why does all this Constructor really do is just call the 'setValue()' method?
   //| Answer: Because it's difficult to call Base's Constructors (because it's hard to often *construct* the necessary parameters using the 
   //|   restricted environment provided by the inherited Class' "Initialization List")
   //|
   //| So the Constructor(s) of this Base class AND the Constructor(s) of any inherited class will do any necessary preparation work then call my 'setValue()' with the correct params
   //+------------------------------------------------------------------+
   void PHPercent::PHPercent( const double dFigure, const int iPrecision = _DEFAULT_PERCENTAGE_PRECISION ) 
   {
      // <Phantom Step occurs here> - Call PHDecimal::PHDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED

      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dFigure: %.8g, iPrecision: %i } ", dFigure, iPrecision ) );

      //Clear out my PHCurrDecimal's Attributes (PHDecimal's Attributes Have already been cleared with the automatic Base Constructor call)
      unsetValue();

      setValue( dFigure, iPrecision );
      
      myLogger.logINFO( StringFormat( "final { value: %s, iPrecision: %i }", this.toString(), this._iPrecision ) );
            
   };  //end Constructor



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
   void PHPercent::setValue( double dFigure, const int iPrecision = _DEFAULT_PERCENTAGE_PRECISION )
   {   
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      // Call Base Class' .setValue() Method 
      // Note that 'Cash Rounding' not applicable for Percentages
      PHDecimal::setValue( dFigure, iPrecision );
      
      if ( (dFigure > 0) && (dFigure < 1) )
         myLogger.logWARN( StringFormat( "Percentages can be set between 0 and 100. If you meant to set a percentage between 0%% and 1%% then fine. Otherwise, if you meant %g%%, set it as %g instead", (dFigure*100), (dFigure*100) ) );
      
      if ( ( dFigure < 0 ) || ( dFigure > 100 ) ) {
         myLogger.logERROR( StringFormat( "params passed { value: %g } is out of bounds - must be between 0 and 100. Object is invalid.", dFigure ) );
         this.unsetValue();
      } //end if

   } //end method











//+------------------------------------------------------------------+
//| PHCurrency
//|
//| An extension of my PHDecimal Class.  
//|
//| In terms of <<Attributes>> it adds:
//|   * Cash Rounding     (no assumptions made, will be set at instantiation)
//|   * Currency Code     (no assumptions made, will be set at instantiation)
//|   * Currency Symbol   (no assumptions made, will be set at instantiation)
//|
//| Overrides the '.toNormalizedDouble()' method
//|   * with one that implements Cash Rounding
//|
//+------------------------------------------------------------------+
class PHCurrency : public PHDecimal 
{
/* <<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

*/
   protected:
      //Protected Attributes
      PH_CURR_CODE      _eCurrCode;         // e.g. EUR
      string            _sCurrSymbol;       // e.g. "$" or "USD" (if you don't provide one)
      double            _dCashRoundingStep; // The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25


// <<< Methods >>>
   public:
      //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHDecimal's Default Construct
                           PHCurrency::PHCurrency() : _eCurrCode(-1), _sCurrSymbol(""), _dCashRoundingStep(-1) {} ;

                           // Parametric Constructor #1 [Elemental] (Regular Constructor) 
                           // Supply 'Currency Code', 'Currency Symbol' and 'Cash Rounding Step'
                           //    If not supplied:
                           //       *  assume a 'Precision' of two digits
                           //       *  assume the 'Currency Symbol' will be the same as Currency Code
                           //       *  assume a 'Cash Rounding Step' that corresponds to a single digit of the 'Precision' (e.g. 2 ==> 0.01 )
                           PHCurrency::PHCurrency( const double dInitialUnits, const  PH_CURR_CODE eCurrCode, const int iPrecision = 2, const string sCurrSymbol = "", const double dCashRoundingStep = -1 );  


      //Public Methods
                           // Same as Parametric Constructor #1 [Elemental] (Regular Constructor) 
         void              PHCurrency::setValue( const double dInitialUnits, const  PH_CURR_CODE eCurrCode, const int iPrecision = 2, const string sCurrSymbol = "", const double dCashRoundingStep = -1 );
         
         void              PHCurrency::unsetValue();
         double            PHCurrency::toNormalizedDouble() const;    // Override PHDecimal::toNormalizedDouble() - I need to incorporate 'Cash Rounding'
         string            PHCurrency::toString() const               // Override PHDecimal::toString()...otherwise it uses PHDecimal's .toNormalizeDouble() !
                           { string sFormatString = StringFormat( "%%s %%.%if", _iPrecision ); return( StringFormat( sFormatString, this._sCurrSymbol, PHCurrency::toNormalizedDouble() ) ); };

}; //end Class PHCurrency



   //+------------------------------------------------------------------+
   //| PHCurrency - Parametric Constructor #1 [Elemental]
   //|
   //| This a skeleton Constructor really.  Why is this so empty? Why does all this Constructor really do is just call the 'setValue()' method?
   //| Answer: Because it's difficult to call Base's Constructors (because it's hard to often *construct* the necessary parameters using the 
   //|   restricted environment provided by the inherited Class' "Initialization List")
   //|
   //| So the Constructor(s) of this Base class AND the Constructor(s) of any inherited class will do any necessary preparation work then call my 'setValue()' with the correct params
   //+------------------------------------------------------------------+
   PHCurrency::PHCurrency( const double dInitialUnits, const  PH_CURR_CODE eCurrCode, const int iPrecision = 2, const string sCurrSymbol = "", const double dCashRoundingStep = -1 )
   {
      // <Phantom Step occurs here> - Call PHDecimal::PHDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED

      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      
      if ( isEnumValid( eCurrCode, PH_CURR_CODE_OFFSET, PH_CURR_CODE_COUNT ) ) {
      
         myLogger.logINFO( StringFormat( "params (Constructor #1) { eCurrCode: %s, sCurrSymbol: %s, dCashRoundingStep: %s } ", EnumToString( eCurrCode ), sCurrSymbol, sFmtDdp( dCashRoundingStep, 5 ) ) );
   
         //Clear out my PCCurrency's Attributes (PHDecimal's Attributes Have already been cleared with the automatic Base Constructor call)
         unsetValue();
   
         setValue( dInitialUnits, eCurrCode, iPrecision, sCurrSymbol, dCashRoundingStep );
         
         myLogger.logINFO( StringFormat( "final (Constructor #1) { eCurrCode: %s, sCurrSymbol: %s, dCashRoundingStep: %s } ", EnumToString( this._eCurrCode ), this._sCurrSymbol, sFmtDdp( this._dCashRoundingStep, 5 ) ) );
      } else
         myLogger.logERROR( StringFormat( "Currency Code '%s' is of the wrong type! ", EnumToString( eCurrCode ) ) );
            
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHCurrency  unsetValue() - Uninitialize/Empty Class Attributes
   //|
   //| 1a./1b. Set eTickerSymbol and sTickerSymbol to NULL
   //|      2. Set Cash Rounding to NULL
   //|      3. Unset Parent Class' values
   //|
   //+------------------------------------------------------------------+
   void PHCurrency::unsetValue() 
   {
      // Unset this Class' mandatory attributes
      
      this._eCurrCode = -1;
      this._sCurrSymbol = "";
      this._dCashRoundingStep = -1;

      PHDecimal::unsetValue();

   }; //end PHCurrency::unsetValue()




   //+------------------------------------------------------------------+
   //| PHCurrency - SetValue()  [Elemental]
   //|
   //| Supply 'Currency Code', 'Currency Symbol' and 'Cash Rounding Step'
   //|    If not supplied:
   //|       *  assume a 'Precision' of two digits
   //|       *  assume the 'Currency Symbol' will be the same as Currency Code
   //|       *  assume a 'Cash Rounding Step' that corresponds to a single digit of the 'Precision' (e.g. 2 ==> 0.01 )
   //| 
   //| Cash Rounding Step used when the multiples of the lowest currency unit differs from Point[i.e. 10^^-Precision]
   //| 
   //+------------------------------------------------------------------+
   void PHCurrency::setValue( const double dInitialUnits, const  PH_CURR_CODE eCurrCode, const int iPrecision = 2, const string sCurrSymbol = "", const double dCashRoundingStep = -1 )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      //Clear out my PHCurrency's Attributes (PHDecimal's Attributes Have already been cleared with the automatic Base Constructor call)
      unsetValue();

      // <<Units and Precision>>
      // Use the Base Class' (PHDecimal's) Method
      // If not supplied, Precision will assumed to be two digits
      PHDecimal::setValue( dInitialUnits, iPrecision );

      // <<<Currency Symbol>>>
      this._eCurrCode = eCurrCode;
      
      
      // <<<Currency Symbol>>>
      // If one has been supplied, then use the 3-character string representation of the Currency Code
      if ( sCurrSymbol == "" )
         this._sCurrSymbol = EnumToString( eCurrCode );
      else
         this._sCurrSymbol = sCurrSymbol;
         
      
      
      // <<Cash Rounding Step>>
      if ( dCashRoundingStep == -1 )
         this._dCashRoundingStep = MathPow( 10, -iPrecision );
      else
        this._dCashRoundingStep = dCashRoundingStep;
      
      myLogger.logINFO( StringFormat( "final (Constructor #1) { eCurrCode: %s, sCurrSymbol: %s, dCashRoundingStep: %s } ", EnumToString( this._eCurrCode ), this._sCurrSymbol, sFmtDdp( this._dCashRoundingStep, 5 ) ) );
   }; //end PHCurrency::setValue





   //+------------------------------------------------------------------+
   //| PHCurrency - toNormalizedDouble()
   //|
   //| This should be the *only* way to retrieve the value 
   //|  (Other retreival methods must be a wrapper around this one)
   //|
   //|   1. Call the PHDecimal::toNormalizedDouble() to:
   //|      a. Cast the units as a Double
   //|         Aside: I considered performing Cash Rounding on a Long - which appears that it would probably work
   //|                (the result of the divide [ Units / VolumeStep ] would get truncated into an Int or Long...but that forces me to always round DOWN/truncate. If I use Doubles, I get to choose how to round)
   //|                But I now cast early because:
   //|                  a) I have to eventually return a Double anyway
   //|                  b) The maths of Steps #2 and #3 become easier using Doubles
   //|
   //|      b. Shift the value to the right (by 'Precision' number of digits)
   //|
   //|   2. Perform Cash Rounding on the Double value
   //|      When the lowest denomination (Tick Value) is the same as the Point Value this initially appears to be an unnecessary step e.g. 1234 ÷ 1 (the equiv of 12.34 ÷ 0.01) 
   //|      But this step becomes necessary when they are different (as in metals) where I must return multiples in a different Step Size e.g. 1234 ÷ 25 (the equiv of 12.34 ÷ 0.25)
   //|
   //+------------------------------------------------------------------+
   double   PHCurrency::toNormalizedDouble() const
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
   };  //end PHCurrency::toNormalizedDouble()




//=====================================================================================================================================================================================================

class PHTicks : public PHCurrency
//   PHTicks subclasses PHCurrency.  It's really just the Counter Currency in an FX Pair
//    All you do is supply a 6-char FX Pair and it...
//    a) automatically derives the PHCurrency's attribute; '_ECurrCode'[enum] from 
//              i) substring of the second currency in the FX Pair
//             ii) the equivalent enumeration of it i.e. 'StringToEnum()'
//    b) <<<TBD>>> It could, in theory, automatically derive the PHCurrency's attribute; '_sCurrSymbol'[string]  from a table of '_eCurrCode' (e.g.  USD => '$' ) e.g. [https://justforex.com/education/currencies]
//       Or, you could leave it blank...and the 3-letter code will be used by default
//    c) overwrites the currency's normal precision with the Ticks' higher Precision; 3 or 5 digits, instead of 2
//       Furthermore, it automatically derives its Precision - from the 'Digits' [TBC]
//    b) automatically derives its Cash Rounding from the TICK_STEP (for the Counter Currency) in the FX Pair
//
//   It adds new Attributes, and adds Tick-specific methods (such as the "CalcStopLossWidth_10dATRx3()" function)
{

/*    //<<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

         //Inherited Attributes from PHCurrency
         PH_CURR_CODE      _eCurrCode;         // (Protected) e.g. EUR
         string            _sCurrSymbol;       // (Protected) e.g. "$" or "USD" (if you don't provide one)
         double            _dCashRoundingStep; // (Protected) The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25


NEW ATTRIBUTES (Protected):
                           //Market Symbol, Ticker Symbol, Stock Symbol, Trading Symbol
         PH_FX_PAIRS       _eTickerSymbol;     // (Protected)  e.g. EURUSD
         string            _sTickerSymbol;     // (Protected) I use both Enum and String representations of Symbol() frequently - it's convenient to store them both



*/
   
      //<<<Protected Attributes>>>
      protected:
//       PHDollar    *_DollarArray[];  // For manually-created PHDollars - Necessary to use Pointers - needed for loop and Delete()

         PHTicks           *_TicksArray[];    // (Protected) For manually-created PHTicks - Necessary to use Pointers - needed for loop and Delete()
         PH_FX_PAIRS       _eTickerSymbol;    // (Protected) e.g. EURUSD
         string            _sTickerSymbol;    // (Protected) I use both Enum and String representations of Symbol() frequently - it's convenient to store them both


      //<<<Private Methods>>>
      private:
//       void        PHTicks::addToDollarArray( PHDollar &oDollar );
         void        PHTicks::addToTicksArray(  PHTicks  &oTick );

      //<<<Public Methods>>>
      public:
         //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHCurrency & PHDecimal's Default Constructor
                           PHTicks::PHTicks() : _eTickerSymbol(-1), _sTickerSymbol("") {}; 

                           // Parametric Constructor #1 [Elemental] (Regular/Partial Constructor) 
                           // (Automatically calls PHCurrency & PHDecimal's Default Constructor
                           PHTicks::PHTicks( const PH_FX_PAIRS eTickerSymbol, const double dInitialUnits = -1 );   

                           // Constructor #2 [Object] (Copy/Constructor)
//                           PHTicks::PHTicks( const PHTicks& that );

                     PHTicks::~PHTicks();
                     
         void        PHTicks::setValue( const PH_FX_PAIRS eTickerSymbol, const double dInitialUnits = -1 );
                     // Kinda like a Constructor, except that *it* derives the actual Units itself
                     // Intent: You would call Constructor #2 to construct an partly-initialized object with a Market Symbol, (which in turn sets Precision and Cash Rounding), then call this to set the Units/mark the Object as COMPLETE
         void        PHTicks::calcStopLossWidth_10dATRx3() ;
         
/* temp removed
         PHDollar PHTicks::tickValueDollarsPerUnit();
         PHDollar PHTicks::tickValueDollarsPerStdContract();
         PHDollar PHTicks::tickValueDollarsForGivenNumLots( PHLots &oLots );

         //This is now supplied by the PHDecimal inherited class...
         string      PHTicks::toString()
                     const { return( sFmtDdp( toNormalizedDouble() ) ); };
*/


}; //end PHTicks Class



   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #1 (Elemental)
   //|
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structure is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const PH_FX_PAIRS eTickerSymbol, const double dInitialUnits = -1 ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dInitialUnits: %.5f, sTickerSymbol: %s }", dInitialUnits, EnumToString( eTickerSymbol ) ) );

      //Set my mandatory Class Attributes
      setValue( eTickerSymbol, dInitialUnits );
     
   }; //end PHTicks:: Constructor




   //+------------------------------------------------------------------+
   //| PHTicks - setValue()
   //|
   //| Takes
   //|   * [mandatory] PH_FX_PAIRS eTickerSymbol
   //|   * [optional]  double dInitialUnits (I'll set the Units to '-1' *and* mark the object as Partially Complete, if missing)
   //|
   //| The parent class's '.setValue()' (within PHCurrency) demands: 
   //|   * [mandatory] double dInitialUnits
   //|   * [mandatory] PH_CURR_CODE eCurrCode
   //|   * [optional]  int iPrecision
   //|   * [optional]  string sCurrSymbol
   //|   * [optional]  double dCashRoundingStep
   //|
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structure is sufficient)
   //+------------------------------------------------------------------+
   void PHTicks::setValue( const PH_FX_PAIRS eTickerSymbol, const double dInitialUnits = -1 )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "setValue { dInitialUnits: %.5f, sTickerSymbol: %s }", dInitialUnits, EnumToString( eTickerSymbol ) ) );
   
      //Set my mandatory Class Attributes
      this._eTickerSymbol = eTickerSymbol;
      this._sTickerSymbol = EnumToString( eTickerSymbol );

      // <<< Currency Code >>>
      // Automatically derive it from the Ticker Symbol
      string sTickerSymbol = EnumToString( eTickerSymbol ); //e.g. EURUSD
      string sCounterCurrency = StringSubstr( sTickerSymbol, 3, 3 );  //e.g. USD
      PH_CURR_CODE eCurrCodeTemplate;
      PH_CURR_CODE eCurrCode = StringToEnum( sCounterCurrency, eCurrCodeTemplate );
      
      // <<< Currency Symbol >>>
      // Ignore for now - it'll revert to the 3-char 'Currency Code'
      string sCurrSymbol;
   
      // <<< Precision >>>
      // Determine the Precision for the market (typially either 3DPs or 5DPs)
      int iPrecision = (int) SymbolInfoInteger( this._sTickerSymbol, SYMBOL_DIGITS );

      // << Cash Rounding >>>
      //Determine the TickSize for the market - will get set as the 'Cash Rounding' Attribute
      double dCashRoundingStep = SymbolInfoDouble( this._sTickerSymbol, SYMBOL_TRADE_TICK_SIZE );  //e.g. 0.0001  (sometimes, might be 0.25 - even if the Point size is 0.01!)

      PHCurrency::setValue( dInitialUnits, eCurrCode, iPrecision, sCurrSymbol, dCashRoundingStep );
      
      // If Units were not specified then mark the object as only Partially Initialized
      if ( dInitialUnits == -1 )
         this._eStatus = OBJECT_PARTIALLY_INITIALIZED;

         
   } // end PHTicks::setValue()
   
   
   
   



/*
   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #2 (Copy Object)
   //|
   //| Copies the Tick Value and Symbol over
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structure is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const PHTicks& oSourcePHTicks ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double      dSourceTickUnits  = oSourcePHTicks.toNormalizedDouble();
      PH_FX_PAIRS eSourceTickSymbol = oSourcePHTicks._eTickerSymbol;

      myLogger.logDEBUG( StringFormat( "Copying PHTick object  (Constructor #2) { dSourceTickUnits: %s, sTickerSymbol: %s }", oSourcePHTicks.toString(), EnumToString( eSourceTickSymbol ) ) );

      //Set my mandatory Class Attributes
      setValue( dSourceTickUnits, eSourceTickSymbol );    

   }; //end PHTicks:: Constructor
*/


   //+------------------------------------------------------------------+
   //| PHTicks - calcStopLossWidth_10dATRx3() (Ten-Day Average Daily True Range x 3)
   //|
   //| It's designed to be used rather like a Constructor. It doesn't take a Tick value - since it will calculate one itself.
   //|   e.g. >      PHTicks ticks_ADTRx10dayCCPriceMoveWidth( Symbol() );             //Declare an empty/uninitialized object
   //|        >      ticks_ADTRx10dayCCPriceMoveWidth.calcStopLossWidth_10dATRx3();    //Now populate the object with a self-derived StopLoss Width
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
   void PHTicks::calcStopLossWidth_10dATRx3() 
   {
   
      LLP(LOG_WARN)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

   
      // Calculate the Average Daily True Range on Daily Bars, for a given symbol/period  (x periods back, starting from yesterday)
      // WARNING: I'm using the *Terminal's* Daily periods (not mine)..but who cares for an ADTR, right?!
         HideTestIndicators(true);
   
//          <<<Code to prove the ADTR is working>>>
//         int stPer = 70;
//   
//            double dADTR_d1 = iATR( sTickerSymbol, PERIOD_D1, 1, stPer );
//            double dADTR_d2 = iATR( sTickerSymbol, PERIOD_D1, 2, stPer );
//            double dADTR_d3 = iATR( sTickerSymbol, PERIOD_D1, 3, stPer );
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
//         CopyTime(sTickerSymbol,PERIOD_D1,stPer,3,Days);
//         CopyLow(sTickerSymbol,PERIOD_D1,stPer,3,Low);
//         CopyHigh(sTickerSymbol,PERIOD_D1,stPer,3,High);
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
   
      if ( this._eStatus == OBJECT_UNITIALIZED ) {
         myLogger.logERROR( "Addition cannot be performed on an uninitialized Object!" );
         
      } else {
         ENUM_TIMEFRAMES ePeriod = PERIOD_D1;
      
         myLogger.logDEBUG( StringFormat( "Constants: 10dATRx3 Averaging Period: %i of %s;  10dATRx3 Multiplier: %f \r\n", _SL10dATRx3_iATRPeriod, EnumToString(ePeriod), _SL10dATRx3_dATRMultiplier ) );
         
         // Step #1 ("Price Width") - a simple ADTR
         // Begin by calculating the ADTR for a (10 x Day) period for my Market/Symbol.  Declare a new Tick Object of the resultant "price width"
         // Using .setValue() to set the Units will also mark the object's status as FULLY_INITIALIZED
         this.setValue( iATR( this._sTickerSymbol, ePeriod, _SL10dATRx3_iATRPeriod, _YESTERDAY), _eTickerSymbol );    // e.g. something like  "0.009339"  If it had a variable it would be: Ticks_ADTRx10dayCCPriceMoveWidth
         
         myLogger.logDEBUG( StringFormat( "Step #1: ATR (Period: %i): %s",    _SL10dATRx3_iATRPeriod, toString() ) );
         HideTestIndicators(false);
      
         // Step #2 ("Price Width") - The ADTR multiplied by a arbitary factor
         // Given the ADTR, now calculate the Stop Loss Width (as a multiple of the ADTR). UoM is a width in terms of the Country Currency's price
         this.multiply( _SL10dATRx3_dATRMultiplier );     // e.g. 0.009339 x 2.9 = 0.02708
   
         // You can now mark the object as Fully Initialized
         this._eStatus = OBJECT_FULLY_INITIALIZED;
   
   
         myLogger.logINFO( StringFormat( "RESULT-> StopLoss Width (in Counter Currency Price): %s \r\n", this.toString() ) );
  
      } // end if

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

   //Note these were originally Private Class Attributes:  - I think that they *may be too static and they may benefit from being pushed into a method so that the rates can be 'Refreshed' upon use - TBC!!!
      double _dTickValueInMarket; //e.g. $1.00
      double _tickValueDollarsPerUnit;   //e.g. $1.00
      double _tickValueDollarsPerStdContract;   //e.g. $1.00
      double _dContractSize;      //e.g. 100,000 units

      _dTickValueInMarket  = SymbolInfoDouble(sTickerSymbol, SYMBOL_TRADE_TICK_VALUE);
      _dContractSize       = SymbolInfoDouble(sTickerSymbol, SYMBOL_TRADE_CONTRACT_SIZE);

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
   
   

   





#ifndef _HANDY

   #define _HANDY

   //------------------------------------------
   //
   // <<<<< HELPER FUNCTIONS >>>>>
   //
   //------------------------------------------

   //+------------------------------------------------------------------+
   //| sFmtDdp  (format to 2 dp with no prefix                                   |
   //+------------------------------------------------------------------+
   string sFmtDdp( const double dValue, const int iPrecision  )
     {
      string sFormat = StringConcatenate( "%.", iPrecision, "f" );
      return(StringFormat( sFormat, dValue ) );
     }
   
   
   
   //+------------------------------------------------------------------+
   //| sFmtMny  (2 dp with a $ prefix                                   |
   //+------------------------------------------------------------------+
   string sFmtMny( const double d )
     {
      return(StringFormat( "$ %.2f", d ) );
     }


   bool  isEnumValid( const int eValue, const int iOffset, const int iCount ) {
      return( ( eValue >= iOffset ) && ( eValue <= ( iOffset + iCount ) ) );
     }



#endif 
//+------------------------------------------------------------------+

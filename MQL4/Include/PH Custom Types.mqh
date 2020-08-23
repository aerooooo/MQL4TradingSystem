
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

enum PH_OPERATOR
  {
   gt,
   gte,
   lt,
   lte,
   eq,
   ne
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
         bool     PHDecimal::operatorAndOperand( const PH_OPERATOR eOp, const PHDecimal& oOperand ) const;
                  
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
   bool     PHDecimal::operatorAndOperand( const PH_OPERATOR eOp, const PHDecimal& oOperand ) const
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
//| PHCurrDecimal
//|
//| An extension of my PHDecimal Class.  It adds:
//|   >> Cash Rounding
//|   >> Market Currency Symbol
//|
//+------------------------------------------------------------------+
class PHCurrDecimal : public PHDecimal 
{
/* <<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

*/
   protected:
      //Protected Attributes
      PH_FX_PAIRS       _eSymbol;
      string            _sSymbol;   //I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
      double            _dCashRoundingStep; // The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25


// <<< Methods >>>
   public:
      //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHDecimal's Default Construct
                           PHCurrDecimal::PHCurrDecimal() : _eSymbol(-1), _sSymbol(""), _dCashRoundingStep(-1) {} ;

                           // Parametric Constructor #1 [Elemental] (Regular Constructor) 
                           // Supply 'Units' and 'Symbol' - it will set the rest
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const PH_FX_PAIRS eSymbol );  

                           // Parametric Constructor #2 [Elemental] (Constructor - used when Cash Rounding Step differs from Point[i.e. 10^^-Precision] )
                           // Constructor - only used for *testing* Cash Rounding (the equivalent .setValue() is used by PHLots though)
                           PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol );  

      //Public Methods
         void              PHCurrDecimal::setValue( const double dInitialUnits, const PH_FX_PAIRS eSymbol );
         void              PHCurrDecimal::setValue( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol );  
         void              PHCurrDecimal::unsetValue();
         double            PHCurrDecimal::toNormalizedDouble() const;    // Override PHDecimal::toNormalizedDouble() - I need to incorporate 'Cash Rounding'
         string            PHCurrDecimal::toString() const               // Override PHDecimal::toString()...otherwise it uses PHDecimal's .toNormalizeDouble() !
                           { string sFormatString = StringFormat( "%%.%if", _iPrecision ); return( StringFormat( sFormatString, PHCurrDecimal::toNormalizedDouble() ) ); };
         string            PHCurrDecimal::objectToString() const
                           { return( StringFormat( "PHCurrDecimal={ CashRoundingStep: %.8f, Symbol: %s, %s }", _dCashRoundingStep, _sSymbol, PHDecimal::objectToString() ) ); };
   protected:
      //Protected Methods
         void              PHCurrDecimal::setPartialValue( const PH_FX_PAIRS eSymbol );
         void              PHCurrDecimal::setValue( const double dInitialUnits );

}; //end Class PHCurrDecimal


   //+------------------------------------------------------------------+
   //| PHCurrDecimal  unsetValue() - Uninitialize/Empty Class Attributes
   //|
   //| 1a./1b. Set eSymbol and sSymbol to NULL
   //|      2. Set Cash Rounding to NULL
   //|      3. Unset Parent Class' values
   //|
   //+------------------------------------------------------------------+
   void PHCurrDecimal::unsetValue() 
   {
      // Set this Class' mandatory attributes
      this._eSymbol = -1;
      this._sSymbol = "";
      this._dCashRoundingStep = -1;
      
      PHDecimal::unsetValue();

   }; //end PHCurrDecimal::unsetValue()


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - Parametric Constructor #1 [Elemental]
   //|
   //| This a skeleton Constructor really.  Why is this so empty? Why does all this Constructor really do is just call the 'setValue()' method?
   //| Answer: Because it's difficult to call Base's Constructors (because it's hard to often *construct* the necessary parameters using the 
   //|   restricted environment provided by the inherited Class' "Initialization List")
   //|
   //| So the Constructor(s) of this Base class AND the Constructor(s) of any inherited class will do any necessary preparation work then call my 'setValue()' with the correct params
   //+------------------------------------------------------------------+
   void PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const PH_FX_PAIRS eSymbol ) 
   {
      // <Phantom Step occurs here> - Call PHDecimal::PHDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED

      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params (Constructor #1) { dInitialUnits: %g, eSymbol: %s } ", dInitialUnits, eSymbol ) );

      //Clear out my PCCurrDecimal's Attributes (PHDecimal's Attributes Have already been cleared with the automatic Base Constructor call)
      unsetValue();

      setValue( dInitialUnits, eSymbol );
      
      myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %g, _dCashRoundingStep: %g }", this.toString(), this._sSymbol, this._iPrecision, this._dCashRoundingStep ) );
            
   };  //end Constructor



   //+------------------------------------------------------------------+
   //| PHCurrDecimal - Parametric Constructor #2 [Elemental]
   //|
   //| I needed a way to test the Cash Rounding functionality
   //| This deliberately overrides the 'iPrecision' and 'dCashRoundingStep' values of the Market with the parameters supplied
   //|
   //| I had to pull out the logic into a Protected Method that PHLots can call.
   //|
   //+------------------------------------------------------------------+
   void PHCurrDecimal::PHCurrDecimal( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol )
   {
      setValue( dInitialUnits, iPrecision, dCashRoundingStep, eSymbol );
   }


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - SetValue() #1  [Elemental]
   //|
   //| Sets Value, Symbol, Precision and Cash Rounding (a.k.a. Tick Size)
   //| used when Cash Rounding Step differs from Point[i.e. 10^^-Precision]
   //| i.e. PHLots requires a Precision of derived from the TICK_SIZE (typically "0.01" ==> Precision: "2") and a Cash Rounding of TICK_STEP_SIZE (typically "0.01", but sometimes "0.25")
   //+------------------------------------------------------------------+
   void PHCurrDecimal::setValue( const double dInitialUnits, const int iPrecision, const double dCashRoundingStep, const PH_FX_PAIRS eSymbol )
   {
      // <Phantom Step occurs here> - Call PHDecimal::PHDecimal() to set the Attributes to NULL - particularly the Object Status to UNINITIALIZED

      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      //Clear out my PCCurrDecimal's Attributes (PHDecimal's Attributes Have already been cleared with the automatic Base Constructor call)
      unsetValue();

      //This will set my Long to the wrong precision (i.e. the precision of the Market, not what's specified. No matter, I'll overwrite it in the next step
      setValue( dInitialUnits, eSymbol );

      //Explicitly override the Units and Precision with my given params above - use the Base Class' (PHDecimal's) Method
      PHDecimal::setValue( dInitialUnits, iPrecision );

      //All that's left to do is set the Cash Rounding
      this._dCashRoundingStep = dCashRoundingStep;
      
      myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %g, _dCashRoundingStep: %g }", this.toString(), this._sSymbol, this._iPrecision, this._dCashRoundingStep ) );
   }; //end PHCurrDecimal::setValue #1


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - SetValue() #2  [Elemental]
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
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
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

   }; //end PHCurrDecimal::setValue #2


   //+------------------------------------------------------------------+
   //| PHCurrDecimal - SetPartialValue()   <Protected> [Elemental]
   //|
   //| Early during initialization there are occiasions where I know the Symbol, but don't have the actual Number (Units) yet.
   //| But even when only given a Symbol, there's sooo much I can derive!...
   //|   For a PHCurrDecimal:  The Market's 'Precision', both forms of the Symbol (String and Enum), the Market's TICK_SIZE (i.e. Cash Rounding)
   //|   For a PHLot:  All of the above...and more: The Min, Max, Step Size and Standard Contract Size for that Lot's Market
   //|
   //| So what we're doing here is setting everything I can (for just PHCurrDecimal)...except the actual Units
   //| So the Constructors are quite different from PHDecimal - All I need to be supplied is: 'Symbol' 
   //|
   //| Object Status
   //| =============
   //| But I'll only mark the Object's Status as PARTIALLY INITIALIZED. 
   //| That'll prevent you from getting an invalid number from it
   //|
   //| (Protected-use only)
   //| Used by:
   //|   >> PHTicks::calcStopLossWidth_10dATRx3()
   //|   >> PHLots::commonConstructor()
   //+------------------------------------------------------------------+
   void PHCurrDecimal::setPartialValue( const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params { sSymbol: %s }", EnumToString( eSymbol ) ) );

      //Set my mandatory Class Attributes
      this._eSymbol = eSymbol;
      this._sSymbol = EnumToString( eSymbol );

      //Determine the TickSize for the market - will get set as the 'Cash Rounding' Attribute
      this._dCashRoundingStep = SymbolInfoDouble( this._sSymbol, SYMBOL_TRADE_TICK_SIZE );  //e.g. 0.0001  (sometimes, 0.25 - even though the Point size is 0.01!)

      // Prepare the PHDecimal object 
      {
         //Determine the Precision for the market (typially either 3DPs or 5DPs)
         int iPrecision = (int) SymbolInfoInteger( this._sSymbol, SYMBOL_DIGITS );
         
         //Set a rogue 'Units'
         PHDecimal::setValue( -1 , iPrecision );
         
         //Mark it as only PARTIALLY INITIALIZED it from returning any values
         this._eStatus = OBJECT_PARTIALLY_INITIALIZED;

         myLogger.logINFO( StringFormat( "final { value: %s, sSymbol: %s, iPrecision: %i, dTickSize: %.8g, _dCashRoundingStep: %.8g }", this.toString(), this._sSymbol, iPrecision, this._dCashRoundingStep ) );
      } // end of PHDecimal prep

   }; //end PHCurrDecimal::setValue #2



   //+------------------------------------------------------------------+
   //| PHCurrDecimal - SetValue()   <Protected> [Elemental]
   //|
   //| Designed to be used only after .setPartialValue() to set only the Units (leaving all the other Attrbutes intact)
   //|
   //| (Protected-use only)
   //| Used by:
   //|   [TBC]  >> PHTicks::calcStopLossWidth_10dATRx3()
   //|   >> PHLots::commonConstructor()
   //+------------------------------------------------------------------+
   void PHCurrDecimal::setValue( const double dUnits )
   {
      LLP( LOG_WARN ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "params { value: %g, }", dUnits ) );
      
      if( this._eStatus == OBJECT_PARTIALLY_INITIALIZED ) {
         this._lUnits = normalizeAndShiftLeft( dUnits );
      } else {
         myLogger.logERROR( "Not allowed to set the value on an UNINITIALIZED (or FULLY INITIALIZED) value. Use '.setValue( double Units, int Precision)' instead" );
      }
      
      //Assume that only the setPartialValue() can set an object to be partially initialized - and hence all the other fields are set correctly
      this._eStatus = OBJECT_FULLY_INITIALIZED;
   }


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











//=====================================================================================================================================================================================================

class PHTicks : public PHCurrDecimal
//   PHTicks adds no new Attributes, but it does add Tick-specific methods (such as the "CalcStopLossWidth_10dATRx3()" function)
{

/*    //<<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

         //Inherited Attributes from PHCurrDecimal
         PH_FX_PAIRS       _eSymbol;           // (Protected)
         string            _sSymbol;           // (Protected) I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
         double            _dCashRoundingStep; // (Protected) The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25

*/
   
      //<<<Protected Attributes>>>
      protected:
//       PHDollar    *_DollarArray[];  //For manually-created PHDollars - Necessary to use Pointers - needed for loop and Delete()
         PHTicks     *_TicksArray[];    //For manually-created PHTicks - Necessary to use Pointers - needed for loop and Delete()


      //<<<Private Methods>>>
      private:
//       void        PHTicks::addToDollarArray( PHDollar &oDollar );
         void        PHTicks::addToTicksArray(  PHTicks  &oTick );

      //<<<Public Methods>>>
      public:
         //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHDecimal's Default Construct
                           PHTicks::PHTicks() {}; 

                           // Parametric Constructor #1 [Elemental] (Regular Constructor) 
                           PHTicks::PHTicks( const double dTicks, const PH_FX_PAIRS eSymbol );   

                           // Constructor #2 [Object] (Copy/Constructor)
                           PHTicks::PHTicks( const PHTicks& that );

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




   //+------------------------------------------------------------------+
   //| PHTicks - Constructor #2 (Copy Object)
   //|
   //| Copies the Tick Value and Symbol over
   //| (Ignores initializing the Destructor's Object Arrays - the initialization that occurs in the Class structre is sufficient)
   //+------------------------------------------------------------------+
   PHTicks::PHTicks( const PHTicks& oSourcePHTicks ) 
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      double      dSourceTickUnits  = oSourcePHTicks.toNormalizedDouble();
      PH_FX_PAIRS eSourceTickSymbol = oSourcePHTicks._eSymbol;

      myLogger.logDEBUG( StringFormat( "Copying PHTick object  (Constructor #2) { dSourceTickUnits: %s, sSymbol: %s }", oSourcePHTicks.toString(), EnumToString( eSourceTickSymbol ) ) );

      //Set my mandatory Class Attributes
      setValue( dSourceTickUnits, eSourceTickSymbol );    

   }; //end PHTicks:: Constructor



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
   
      LLP(LOG_WARN)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

      myLogger.logDEBUG( StringFormat( "param(s) { eSymbol: %s }", this._sSymbol ) );

/*   
      // Set my mandatory Class Attributes
      //   In this case, all I've actually been given is the Symbol at this stage.  But I can work out the 'TickSize' and 'Precision' from that.
      //   For now, I'll set a dummy value for Ticks/Price - but by the end of the method, I'll have calculated the Tick/Price Move Width and set it at the end of the method
      //   Why set anything at all?  Because all the other attributes can be set. All we're missing is the Units. [EDIT] I really, really need the 'CashRoundingStep' set early on!
      setValue( 1, eSymbol );    //Ticks = 1 (DUMMY VALUE - I will re-set once I have the correct value later)

      // Override Object Status with 'Partially Initialized'.  This will prevent it from >>>returning any bad values<<< (specifically via ".toNormalizedDouble()'. 
      // I'll set it to fully initialized when I've set the correct Ticks value
      this._eStatus = OBJECT_PARTIALLY_INITIALIZED;
*/
      //Replacement for above
      setPartialValue( eSymbol );     
   
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
      
      // Step #1 ("Price Width") - a simple ADTR
      // Begin by calculating the ADTR for a (10 x Day) period for my Market/Symbol.  Declare a new Tick Object of the resultant "price width"
      // Using .setValue() to set the Units will also mark the object's status as FULLY_INITIALIZED
      this.setValue( iATR( this._sSymbol, ePeriod, _SL10dATRx3_iATRPeriod, _YESTERDAY), _eSymbol );    // e.g. something like  "0.009339"  If it had a variable it would be: Ticks_ADTRx10dayCCPriceMoveWidth
      
      myLogger.logDEBUG( StringFormat( "Step #1: ATR (Period: %i): %s",    _SL10dATRx3_iATRPeriod, toString() ) );
      HideTestIndicators(false);
   
      // Step #2 ("Price Width") - The ADTR multiplied by a arbitary factor
      // Given the ADTR, now calculate the Stop Loss Width (as a multiple of the ADTR). UoM is a width in terms of the Country Currency's price
      this.multiply( _SL10dATRx3_dATRMultiplier );     // e.g. 0.009339 x 2.9 = 0.02708

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

   //Note these were originally Private Class Attributes:  - I think that they *may be too static and they may benefit from being pushed into a method so that the rates can be 'Refreshed' upon use - TBC!!!
      double _dTickValueInMarket; //e.g. $1.00
      double _tickValueDollarsPerUnit;   //e.g. $1.00
      double _tickValueDollarsPerStdContract;   //e.g. $1.00
      double _dContractSize;      //e.g. 100,000 units

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

class PHLots : public PHCurrDecimal 
{

// PHLots adds new Attributes:  
//    >> Minimum Lot Size (typically 0.01)
//    >> Maximum Lot Size (typically 50.0)
//    >> Lot Step Size (typically 0.01)
//    >> Standard Contract Size (typically 100,000)

// PHLots performs a validation step before setting its attributes (similar to PHPercent)

// PHLots must be defined after PHTicks  (I use PHTicks in the methods)

// I use Cash Rounding to ensure that only multiple of Lot size (minimum of 0.01, in multiles of 0.01 and a maximum of 50) are returned.
// Lots may be temporarily breach those rules within this class (while being calculated, for example) but ultimately must comply to the above rules

/*    //<<<Attributes>>>
         //Inherited Attributes from PHDecimal
         PH_OBJECT_STATUS  _eStatus;      // (Public) I should make this private and only accessible via a "is" method, but Hey (shrug)
         long              _lUnits;       // (Protected) The decimal value (Stored as a Long)
         int               _iPrecision;   // (Protected) Precision of your value a.k.a. "the minimum unit of account"  e.g. '2' represents 2dp or 0.01

         //Inherited Attributes from PHCurrDecimal
         PH_FX_PAIRS       _eSymbol;           // (Protected)
         string            _sSymbol;           // (Protected) I use both Enum and String representations of Symbol() frequently, so I reckon it's worth storing them both
         double            _dCashRoundingStep; // (Protected) The lowest physical denomination of currency [https://en.wikipedia.org/wiki/Cash_rounding]. e.g. 0.25

*/

      //<<<Private Attributes>>>
      private:
//         double    _dVolumeMin, _dVolumeStep, _dVolumeMax, _dStandardContractSize;
           PHDecimal _volumeMin_Decimal, _volumeStep_Decimal, _volumeMax_Decimal, _stdCntSize_Decimal;  //Obviously all initially, un-initialized


      //<<<Public Methods>>>
      public:
         //Constructors
                           // Default Constructor (empty body: {}) - construct an UNINITIALIZED object (necessary for when you include one in a Structure/Class)
                           // (Automatically calls PHCurrDecimal's Default Constructor (which in turn calls PHDecimal's Default Constructor)
                           PHLots::PHLots() {};

                           // Parametric Constructor #1 [Elemental] (Regular Constructor) 
                           PHLots::PHLots( const double dLots, const PH_FX_PAIRS eSymbol );

         void              PHLots::setValue( const double dLots, const PH_FX_PAIRS eSymbol );
         void              PHLots::sizePercentRiskModel( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHPercent& oPercentageOfEquityToRisk );
         string            PHLots::objectToString() const
                           { return( StringFormat( "PHLots={ LOT_MIN: %s, LOT_MAX: %s, LOT_STEP: %s, LOT_SIZE: %s, %s }", _volumeMin_Decimal.toString(), _volumeMax_Decimal.toString(), _volumeStep_Decimal.toString(), _stdCntSize_Decimal.toString(), PHCurrDecimal::objectToString() ) ); };

/* old way...
         double   PHLots::getVolumeMin()            const { return _dVolumeMin; };
         double   PHLots::getVolumeMax()            const { return _dVolumeMax; };
         double   PHLots::getVolumeStep()           const { return _dVolumeStep; };
         double   PHLots::getStandardContractSize() const { return _StandardContractSize; };
*/


      //<<<Private Methods>>>
      private:
         void              PHLots::commonConstructor( const PH_FX_PAIRS eSymbol );


      //<<<Protected Methods>>>
      protected:
         void              PHLots::unsetValue();

}; //end Class


   //+------------------------------------------------------------------+
   //| PHLots - Common Constructor a.k.a Constructor #0 (Common/Environment (No Params))
   //|
   //+------------------------------------------------------------------+
   void  PHLots::commonConstructor( const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_INFO ) //Set the 'Log File Prefix' and 'Log Threshold' for this function

      //Set everything - except the Units
      this.setPartialValue( eSymbol );
      
      //Unfortunately the 'Precision' is wrong - it's been set to the Market Digits (typically 3 or 5), when it's more likely 2 (Min Lot Size: 0.01)
      //Unfortunately the 'Cash Rounding ' is also wrong - again, it's been set to the Market Point (typically 0.001 or 0.00001), when it's more likely 0.01 (Min Lot STEP Size: 0.01)
      // Given, the Minimum Lots Size (typically 0.01), calculate the number of decimal points:
      int iPrecision = 0;
      
      {
         double dMinLots = SymbolInfoDouble( EnumToString(eSymbol), SYMBOL_VOLUME_MIN );
         dMinLots = MathAbs( dMinLots );
         dMinLots = dMinLots - int( dMinLots );
         while ( MathAbs(dMinLots) >= 0.0000001 )  //Floating Point workaround. But it's safe to assume in this case (Lots) there's only a limited number of digits after the decimal point (i.e like 0.01, and NOT like .2156 (= .21559999999999) or 'two-thirds' for example)
         {
          dMinLots = dMinLots * 10;
          iPrecision++;
          dMinLots = dMinLots - int(dMinLots);  // This ensures that the final digit gets eventually removed (leaving "close to" zero)
         };
      }

      _volumeMin_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MIN ), iPrecision );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MIN = %s (minimal volume for a deal)", _volumeMin_Decimal.toString() ) );

      _volumeMax_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_MAX ), iPrecision );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_MAX = %s (maximum volume for a deal)", _volumeMax_Decimal.toString() ) );

      double dCashRoundingStep = SymbolInfoDouble( _sSymbol, SYMBOL_VOLUME_STEP );
      _volumeStep_Decimal.setValue( dCashRoundingStep, iPrecision );
      myLogger.logDEBUG( StringFormat( "SYMBOL_VOLUME_STEP = %s (deal volume increase step size)", _volumeStep_Decimal.toString() ) );

      _stdCntSize_Decimal.setValue( SymbolInfoDouble( _sSymbol, SYMBOL_TRADE_CONTRACT_SIZE ), iPrecision );
      myLogger.logDEBUG( StringFormat( "SYMBOL_TRADE_CONTRACT_SIZE = %s (numner of Lots/units to a standard contract)", _stdCntSize_Decimal.toString() ) );
      
      //Finally, correct the 'Precision' and 'Cash Rounding'
      this._iPrecision = iPrecision;
      this._dCashRoundingStep = dCashRoundingStep;

      this._lUnits = -1;   //set it to a rogue value; no other reason than I like to see that in the debugger!0
      
   };



   //+------------------------------------------------------------------+
   //| PHLots - Constructor #1 (Elemental)
   //|
   //+------------------------------------------------------------------+
   PHLots::PHLots( const double dLots, const PH_FX_PAIRS eSymbol )
   {
      setValue( dLots, eSymbol );

   }; //end PHLots:: Constructor


   //+------------------------------------------------------------------+
   //| PHLots - setValue() (Elemental)
   //|
   //+------------------------------------------------------------------+
   void PHLots::setValue( const double dLots, const PH_FX_PAIRS eSymbol )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
      myLogger.logINFO( StringFormat( "passed params { dValue: %f, sSymbol: %s }", dLots, EnumToString(eSymbol) ) );

      PHLots::commonConstructor( eSymbol );

      //Optimistically set the Value (Call to PHCurrDecimal::setValue() ) - I'll test and .unset() later if necessary
      
      PHCurrDecimal::setValue( dLots );
      
      myLogger.logDEBUG( StringFormat( "Lots Units: %s", this.toString() ) );
      myLogger.logDEBUG( StringFormat( "Max Lot Size: %s", _volumeMax_Decimal.toString() ) );
      myLogger.logDEBUG( StringFormat( "Min Lot Size: %s", _volumeMin_Decimal.toString() ) );

      if ( this.operatorAndOperand( gt, _volumeMax_Decimal ) ) {
         // i.e. failed the "dLots > LOTS_MAX_SIZE" test
         myLogger.logERROR( StringFormat( "Attempt to set Lots (%g) to greater than MAX_LOT_SIZE (%s)", _volumeMax_Decimal.toString() ) );

         unsetValue();  //Calls PHCurrDecimals' unsetValue() <<CONFIRM   (anyhow, PHLots doesn't need it's own one)
      } 
      
      if ( this.operatorAndOperand( lt, _volumeMin_Decimal ) ) {
         // i.e. failed the "dLots < LOTS_MIN_SIZE" test
         myLogger.logERROR( StringFormat( "Attempt to set Lots (%g) to less than MIN_LOT_SIZE (%s)", _volumeMin_Decimal.toString() ) );

         unsetValue();  //Calls PHCurrDecimals' unsetValue() <<CONFIRM   (anyhow, PHLots doesn't need it's own one)
      } 
   }; //end PHLots::setValue()


   //+------------------------------------------------------------------+
   //| PHLots unsetValue() - Uninitialize/Empty Class Attributes
   //|
   //| 1a./1b. Set eSymbol and sSymbol to NULL
   //|      2. Set Cash Rounding to NULL
   //|      3. Unset Parent Class' (PHCurrDecimal) values (who will unset the grandfather Class' - PCDecimal)
   //|
   //+------------------------------------------------------------------+
   void PHLots::unsetValue() 
   {
      // Unset this Class' mandatory attributes
      this._volumeMin_Decimal.unsetValue();
      this._volumeStep_Decimal.unsetValue();
      this._volumeMax_Decimal.unsetValue();
      this._stdCntSize_Decimal.unsetValue();
      
      PHCurrDecimal::unsetValue();
   
   }; //end PHLots::unsetValue()






/* temp disabled...

   //+------------------------------------------------------------------+
   //| PHLots - sizePercentRiskModel() (Derive num Lots given a StopLossWidth)
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
   void  PHLots::sizePercentRiskModel( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHPercent& oPercentageOfEquityToRisk )
   {
      LLP( LOG_DEBUG ) //Set the 'Log File Prefix' and 'Log Threshold' for this function
   
      string sSymbol = EnumToString( eSymbol );
      myLogger.logDEBUG( StringFormat( "passed params { sSymbol: %s, StopLoss Width: %s, oPercentageOfEquityToRisk: %f }", sSymbol, oTicks_StopLossWidth.toString(), oPercentageOfEquityToRisk.getFigure() ) );

//Call to Super() ???
//PHLots::PHLots0( sSymbol );


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
   
...*/






////Dollars must be defined after Ticks and Lots
//class PHDollar {
//      //<<<Private Attributes>>>
//      private:
//         double _amt;
//
//      //<<<Public Methods>>>
//      public:
//                  //Constructors
//                  PHDollar::PHDollar( const double amt )
//                     { this._amt = amt; };
//                  PHDollar::PHDollar( const PHDollar& dlr )    //Copy Constructor
//                     { this._amt = dlr._amt; };
//                  PHDollar::PHDollar( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHLots& oLots );  //Complex Constructor (previously known as the 'Ticks2ValueCalculator()' function)
//
//         string   PHDollar::toString()
//                     //{ return(StringFormat( "$ %.2f", _amt ) ); };
//                     const { return( sFmtMny( toNormalizedDouble() ) ); };
//         double   PHDollar::toNormalizedDouble()
//                     const { return( NormalizeDouble( _amt, 2 ) ); };    //This will round to the necessary # digits, but may not *display* them to the desired format!
//         void     PHDollar::freeMarginAfterOrder( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES& eOrderType, const PHLots& numLots );
//}; //end Class
//
//   //+------------------------------------------------------------------+
//   //| PHDollar   Constructor #3 (previously known as the 'Ticks2ValueCalculator()' function)
//   //|
//   //| Formula: (Price Move / (Value of a tick in Deposit Currency ) * Value of a tick in Quote Currency ) * Num of Lots
//   //| Note:
//   //|   - formula uses fractions of a Lot, NOT units!
//   //|   - formula uses ticks, not Points.  For an explanation, see http://forum.mql4.com/33975
//   //|   - the result may not necessarily equal the sale value, unless you've already factored the spread into the Price Move
//   //|
//   //| Takes: the Price Move difference (between two Price Levels) in terms of the counter currency, and a Lot size
//   //| Returns: Calculates the value of a position
//   //|
//   //| Why is the Bid/Ask not involved here??  
//   //|   a) Because the spread is insignificant?  (not sure, but don't think so)
//   //|   b) Because my Stop Loss value will be calculated *after* the sale/slippage has been estabished  (MORE LIKELY ANSWER)
//   //| 
//   //| Gets called by (called *twice* before opening a trade):
//   //|   1. sizePercentRiskModel() - initially to figure out the cost of opening a full (1.0) Lot  (which is typically too much)
//   //|   2. openTradeAtMarket()    - 2nd time: after I've figured out how much I can afford to risk, to figure out the cost to take the actual position
//   //+------------------------------------------------------------------+
//   
//   
//   //Ray reckons: PositionValueChange = PriceChangeInPips * MarketInfo( OrderSymbol(), MODE_TICKVALUE) * OrderLots();
//   //auto_free_cloudbreaker reckons: ( MarketInfo( Symbol(), MODE_TICKVALUE) * Point ) / MarketInfo( Symbol(), MODE_TICKSIZE )
//   
//   PHDollar::PHDollar( const PH_FX_PAIRS eSymbol, const PHTicks& oTicks_StopLossWidth, const PHLots& oLots )
//   {
//      LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function
//      string sSymbol = EnumToString( eSymbol);
//   
//      PHDollar oValueOf1Tick_USD( SymbolInfoDouble( sSymbol, SYMBOL_TRADE_TICK_VALUE ) );
//      myLogger.logDEBUG( StringFormat("Num Lots: %s; Stop Loss (in Ticks): %s;  ValueOf1Tick_USD: %s",   oLots.toString(), oTicks_StopLossWidth.toString(), oValueOf1Tick_USD.toString() ) );
//
//      this._amt = ( oTicks_StopLossWidth.toNormalizedDouble() * oValueOf1Tick_USD.toNormalizedDouble() * oLots.toNormalizedDouble() /* [TODO]  * oLots.getStandardContractSize() */   );
//      myLogger.logINFO(StringFormat("ValueOfPosition (in Deposit Currency/USD): %s",   this.toString() ) );
//   
//         //OLD/Working[but poor UoM choice]: Money valueInUSD = (dPriceMove / MarketInfo( sSymbol, MODE_TICKSIZE ) ) * MarketInfo( sSymbol, MODE_TICKVALUE ) * dBallparkLots;
//         //   double valueInUSD = dPriceMove * (MarketInfo(Symbol(),MODE_TICKVALUE)*Point)/MarketInfo(Symbol(),MODE_TICKSIZE) * (dLots * MarketInfo( Symbol(), MODE_LOTSIZE ) );  incorrect!!!
//   
//      //return(dValueOfPosition_USD);
//   };
//   
//
//
//   //+------------------------------------------------------------------+
//   //| PHDollar   freeMarginAfterOrder
//   //|
//   //+------------------------------------------------------------------+
//   void     PHDollar::freeMarginAfterOrder( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES& eOrderType, const PHLots& numLots )
//   {
//      LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function
//   
//      string sSymbol = EnumToString( eSymbol);
//      
//      PHDollar oFreeMarginPriorToTrade( AccountFreeMargin() );
//      
//      this._amt = AccountFreeMarginCheck( sSymbol, eOrderType, numLots.toNormalizedDouble() );
//      int iError = GetLastError();
//      if( ( this._amt <= 0) || (iError == 134) )
//         myLogger.logERROR( StringFormat( "Free margin is insufficient! (symbol: %s, num lots: %s)", sSymbol, numLots.toString() ) );
//
//      PHDollar oEstPosValue( ( oFreeMarginPriorToTrade.toNormalizedDouble() - this._amt ) * AccountLeverage() );
//      PHPercent oAvailPercentMarginAfterTrade( this._amt / oFreeMarginPriorToTrade.toNormalizedDouble(), 2 );
//      myLogger.logINFO( StringFormat( "Estimated Position Value: %s (figures not accurate until after order and Slippage taken into account)", oEstPosValue.toString() ) );
//
//      myLogger.logINFO(StringFormat("FYI Margin Required to open one Lot: $ %.2f", MarketInfo(sSymbol, MODE_MARGINREQUIRED)));
//      myLogger.logINFO(StringFormat("Testing a %s of %s lots at the appropriate Price determined by the \'AccountFreeMarginCheck()\' function", EnumToString(eOrderType), numLots.toString() ));
//      myLogger.logINFO(StringFormat("\tThe \'MarketInfo(MODE_MARGINREQUIRED)\' function states that you will require $ %.2f of Margin to buy one Lot", MarketInfo(sSymbol, MODE_MARGINREQUIRED) ) );
//      myLogger.logINFO(StringFormat("\tThe \'AccountFreeMarginCheck\' (%s %s lots of %s) function returns $ %s meaning it must use up $ %.2f of margin [\'Available Margin prior to trade\' minus the \'Estimated free margin after trade\' (from function)]", EnumToString(eOrderType), numLots.toString(), sSymbol, this.toString(), ( oFreeMarginPriorToTrade.toNormalizedDouble() - this.toNormalizedDouble() ) ) );
//      myLogger.logINFO(StringFormat("\t\tor put as a percentage, you would still have: %s %% of Available Margin left after the trade", sFmt2dp(oAvailPercentMarginAfterTrade.getFigure() ) ));
//      myLogger.logINFO(StringFormat("\t\tThe Account Stop Out Level: %s", sFmtDdp(AccountStopoutLevel())));
//   
//   };
//   




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

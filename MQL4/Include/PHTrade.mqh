//+------------------------------------------------------------------+
//|                                                      PHTrade.mqh |
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

#define _trades 1



struct OrderOpen_Properties {
   double            dREQ_OPEN_PRICE;     // Requested Opening Price of the order (to report slippage). Set once, upon opening the trade.
   double            dACT_OPEN_PRICE;     // <NOT USED YET> Actual Opening Price of the order (to report slippage). Set once, upon opening the trade.

   int               iTICKET_NUMBER;      // Holds the Server Order Ticket Number (NOT the Magic ID). Set once, upon opening the trade.
   int               iMAGIC_ID;           // Magic ID. Set once, upon opening the trade.
   
   
   PH_ORDER_TYPES    eORDER_TYPE;      // ORDER_BUY/ORDER_SELL (my custom type codes, not the MQL ones!) Set once, upon opening the trade.
   datetime          dtOPEN_DATETIME;     // Datetime (stored as an int). Set once, upon opening the trade.

   PH_ENTRY_REASONS  eREASON_OPEN_TYPE;   // Reason for opening the order (primary MA crossover, pyramid, add-to-position, intraday etc). Set once, upon opening the trade.
   int               iUNITS;              // Number of units (safer than storing the number of lots). Set once, upon opening the trade.
   string            sSYMBOL;             // Currency pair of the order.  Set once, upon opening the trade.
   string            sCOMMENT;            // Freeform textual comment.  Set once, upon opening the trade.


};



struct OrderClose_Properties {
   double            dREQ_CLOSE_PRICE;       // <NOT USED YET> Requested Closing Price of the order (to report slippage). Set once, upon closing the trade.
   double            dACT_CLOSE_PRICE;       // <NOT USED YET> Actual Closing Price of the order (to report slippage). Set once, upon closing the trade.
   double            dSTOPLOSS;              // <NOT USED YET> Last known/set value of the stoploss for the order (to report slippage). Set multiple times; a) upon opening the trade, b) every time the Trade's StopLoss was modified
   double            dTAKEPROFIT;            // (NEVER SET) Last known/set value of the Takeprofit for the order (to report slippage). Set multiple times; a) upon opening the trade, b) every time the Trade's TakeProfit was modified

   datetime          dtCLOSE_DATETIME;    // Datetime (stored as an int). Set once, upon closing the trade.
// The 'OrderExpiration()' attribute is deliberately ignored - if the order expires it never becomes a closed trade anyway
   PH_EXIT_REASONS   eREASON_CLOSE_TYPE;  // Reason for closing the order (primary MA crossover, Stopped Out, Profit Retainment). Optimistically set. Set once, upon closing the trade.
   string            sREASON_CLOSE_TEXT;  // Textual reason for closing the order. Optimistically set. Set multiple times, for mutliple reasons; a) upon opening the trade, b) upon modifying the trade

};


struct Account_Properties {
   double            dPRIOREQUITY;           // Account Equity prior to order. Set once, upon opening the trade.
   double            dPRIORBALANCE;          // Account Balance prior to order. Set once, upon opening the trade.
   double            dPRIORFREEMARGIN;       // Account Free Margin prior to order. Set once, upon opening the trade.
   double            dLEVERAGE;              // Account Leverage at the time of the order. Although actually an integer, it makes sense to store it as a float since it's typically used in decimal calculations anyway. Set once, upon opening the trade.

};


struct Market_Properties {
   double            dOPEN_SPREAD;           // Spread at the time of opening the order. Set once, upon opening the trade.
   double            dCLOSE_SPREAD;          // Spread at the time of closing the order. Set once, upon closing the trade.
   double            dREQ_OPEN_TICKVAL;      // Tick value (in terms of Deposit Currency) at time of Open. Set once, upon opening the trade.
   double            dREQ_CLOSE_TICKVAL;     // Tick value (in terms of Deposit Currency) at time of Close. Set once, upon closing the trade.

};

struct Trade_Properties {

   double            dRISK_VALUE;            // Risk Value ($) for the order. Set once, upon opening the trade.
   double            dRMULTIPLE;             // R-Multiple (2dp). Set once, upon closing the trade.
   double            dMIN_FAV_EXCURSION;     // MFE (Minimum Favorable Excursion) for each trade. Set multiple times (but for only one reason); at the start of the next day
   double            dMAX_ADV_EXCURSION;     // MAE (Maximum Adverse Excursion) for each trade. Set multiple times (but for only one reason); at the start of the next day
   double            dPEAK_PROFIT;           // Peak Profit for each trade.  Set multiple times (but for only one reason) by the 'Stats' Module at the start of the next day 
   double            dFINAL_PROFIT;          // Final/closing Profit/Loss for each trade.  Set once, upon closing the trade.
   double            dSWAP;                  // Swap(?).  Set once, upon closing the trade.
   double            dCOMMISSION;            // Commission(?).  Set once, upon closing the trade.

   PH_TRADE_STATUS   eSTATUS_FLAG;           // WTO/Open/Close/WCO  Order Flag  //Orders can get closed (Stopped Out) before this flag gets set. Set twice, a) upon opening the trade and b) upon closing the trade.
   int               iTREND_CYCLE_IDX;       // Trend Cycle Identifier (index into 'aTrendHistory[]' array). Set once, upon closing the trade.


};

class PHTrade {
   
   //<<< PUBLIC METHODS >>>
   public:
                     PHTrade( string sSymbol ) { _sSymbol = sSymbol; }// ;
                    ~PHTrade();
            //void     setSymbol( string s ) { _sSymbol = s; };
            void     setLots( Lots l ) { _dLots = l; };
            bool     PHTrade::setOpeningProperties( int iOrderMagicID, int iOrderTicketNumber, double dRiskValueForPosition, double dAccountEquityPriorToTrade, double dAccountBalancePriorToTrade, double dFreeMarginPriorToTrade, int iAccountLeverage, double dSpread, double dRequestedPriceAtOpen, PH_ENTRY_REASONS eReasonOpenType, double dTickValueAtOpen );

   //<<< PRIVATE METHODS >>>
   private:



   //<<< PRIVATE ATTRIBUTES >>>
   private:

      //Private Attributes CONSTANTS
            //int      _SystemMagicIdClass;   
                     //MagicID is a bitwise field. The first digit(s) will indicate this algorithm. 
                     //The last '_MAE_INDEX_DIGITS' (FOUR) digits will indicate the trade number (and the index into the nMAEHistory array)

            string   _sSymbol;
            Lots     _dLots;
            OrderOpen_Properties    _OrderOpenProps_STRUCT;
            OrderClose_Properties   _OrderCloseProps_STRUCT;
            Account_Properties      _AccountProps_STRUCT;
            Market_Properties       _MarketProps_STRUCT;
            Trade_Properties        _TradeProps_STRUCT;
            

};  //end Class Header


//+------------------------------------------------------------------+
//|  Constructor
//+------------------------------------------------------------------+
//PHTrade::PHTrade() {  }




//+------------------------------------------------------------------+
//|  Destructor
//+------------------------------------------------------------------+
PHTrade::~PHTrade() {
}


//+------------------------------------------------------------------+
//| setOpeningProperties
//|
//|   Sets a whole bunch of Order Journal properties - at the time the order is opened
//|   although the StopLossPrice is passed, it doesn't actually get written here (it's already held as an built-in order property). It's used to set the optimistic _OJ_ORDPROP_kREASON_CLOSE_TYPE (close reason) property
//| See also setOpeningProperties2.OJ() for more settings!
//| In case of any issues with the Orders Journal whatsoever (e.g. the OJ failed to expand), I will panic the information to the trace file
//|
//| Takes: an Order MagicID #    (Derives the correct Orders Journal index using the last three digits of the Order Magic Number)
//| Returns: bool (success/fail)
//+------------------------------------------------------------------+

//note that 'dStopLossPrice'(double) and 'sReasonClosedText'(string) have deliberately been removed from here - they now get set by "OrderModifyStopLoss()" instead
bool PHTrade::setOpeningProperties( int iOrderMagicID, int iOrderTicketNumber, double dRiskValueForPosition, double dAccountEquityPriorToTrade, double dAccountBalancePriorToTrade, double dFreeMarginPriorToTrade, int iAccountLeverage, double dSpread, double dRequestedPriceAtOpen, PH_ENTRY_REASONS eReasonOpenType, double dTickValueAtOpen ) {
   LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

   myLogger.logDEBUG( StringFormat( "{start} Supplied MagicID # %i", iOrderMagicID ) );

   bool bStatus;

      _TradeProps_STRUCT.dRISK_VALUE         = dRiskValueForPosition;
      _TradeProps_STRUCT.dMIN_FAV_EXCURSION  = 0;
      _TradeProps_STRUCT.dMAX_ADV_EXCURSION  = 0;
      _TradeProps_STRUCT.dPEAK_PROFIT        = 0;
      
      _AccountProps_STRUCT.dPRIOREQUITY      = dAccountEquityPriorToTrade;
      _AccountProps_STRUCT.dPRIORBALANCE     = dAccountBalancePriorToTrade;
      _AccountProps_STRUCT.dPRIORFREEMARGIN  = dFreeMarginPriorToTrade;
      _AccountProps_STRUCT.dLEVERAGE         = (double) iAccountLeverage;  //Actually an int, but stored as a decimal (to make decimal calcs easier/safer)
      
      _MarketProps_STRUCT.dOPEN_SPREAD       = dSpread_Ticks;
      _OrderOpenProps_STRUCT.dREQ_OPEN_PRICE = dRequestedPriceAtOpen;
      _MarketProps_STRUCT.dREQ_OPEN_TICKVAL  = dTickValueAtOpen;
      //ORDPROP_dSTOPLOSS, dStopLossPrice; //moved to "OrderModifyStopLoss()"

      _OrderOpenProps_STRUCT.iMAGIC_ID       = iOrderMagicID;
      _OrderOpenProps_STRUCT.iTICKET_NUMBER  = iOrderTicketNumber;
      _OrderOpenProps_STRUCT.eREASON_OPEN_TYPE = eReasonOpenType;
      _TradeProps_STRUCT.eSTATUS_FLAG          = TRDSTATUS_WAITINGTOOPEN;
      //ORDPROP_iOPENING_BAR, iOpeningBarNumber;
      _OrderCloseProps_STRUCT.eREASON_CLOSE_TYPE = EXIT_not_specified;    //Set an "EXIT_not_specified" as default for now.  However if StopLoss Enabled, then the 'OrderModifyStopLoss()' will shortly overwrite this with an EXIT_INITIAL_STOP. Also remember, it may get overwritten with something else much later as the trade progresses
      
      // _OJ_ORDPROP_sREASON_CLOSE_TEXT, sReasonClosedText;      //moved to "OrderModifyStopLoss()"
      
      myLogger.logDEBUG( StringConcatenate( "iOrderMagicID: ", iOrderMagicID, "; iOrderTicketNumber: ", iOrderTicketNumber, "; dRiskValueForPosition: ", sFmtMny( dRiskValueForPosition ), "; dAccountEquityPriorToTrade: ", sFmtMny( dAccountEquityPriorToTrade ), "; dAccountBalancePriorToTrade: ", sFmtMny( dAccountBalancePriorToTrade ), "; dFreeMarginPriorToTrade: ", sFmtMny( dFreeMarginPriorToTrade ), "; AccountLeverage: ", AccountLeverage(), "; dSpread: ", sFmtDdp( dSpread ), "; dRequestedPrice: ", sFmtDdp( dRequestedPriceAtOpen ), "; eReasonOpenType: ", eReasonOpenType, "; TickValueAtOpen: ", sFmtDdp( MarketInfo( Symbol(), MODE_TICKVALUE ) ) ) );

   return( bStatus );   //success/fail
}



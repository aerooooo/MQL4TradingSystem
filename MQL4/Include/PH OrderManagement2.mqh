//+------------------------------------------------------------------+
//|                                          PH OrderManagement2.mqh |
//|                                                      HearMonster |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "HearMonster"
#property link      "https://www.mql4.com"
#property strict


//TO THINK ABOUT
/*
The 'dCalcStopLossWidth_10dATRx3()' function is fixed on Daily Bars, not relative to the time period I'm working on
- I think this is correct... right?
*/


#ifndef _logger
   #include <PHLogger.mqh>
#endif

#ifndef _custom_types
   #include <PH Custom Types.mqh>
#endif 



class PHOrderManagement2
  {
   //<<< PUBLIC METHODS >>>
   public:
                        PHOrderManagement2();
                       ~PHOrderManagement2();
                  int   PHOrderManagement2::openTradeAtMarket( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES eMyOrderTypeCode, const PH_ENTRY_REASONS eReasonOpenType, const PHPercent& oPercentageOfEquityToRisk, const bool isFakeTrade = false );
   
   
      //<<< PRIVATE METHODS >>>
   private:

   
      //<<< PRIVATE ATTRIBUTES >>>
   private:
      int               _SystemMagicIdClass;
      //MagicID is a bitwise field. The first digit(s) will indicate this algorithm.
      //The last '_MAE_INDEX_DIGITS' (FOUR) digits will indicate the trade number (and the index into the nMAEHistory array)
   

  };


//+------------------------------------------------------------------+
//|  Constructor
//+------------------------------------------------------------------+
PHOrderManagement2::PHOrderManagement2()
  {

   _SystemMagicIdClass = 2;   //MagicID is a bitwise field. The first digit(s) will indicate this algorithm.
//The last '_MAE_INDEX_DIGITS' (FOUR) digits will indicate the trade number (and the index into the nMAEHistory array)

  }


//+------------------------------------------------------------------+
//|  Destructor
//+------------------------------------------------------------------+
PHOrderManagement2::~PHOrderManagement2()
  {
  }



//+------------------------------------------------------------------+
//| openTradeAtMarket
//|
//| Place a Buy or Sell Order at Market Price
//| Takes
//|   a) a (custom) Order Type (ORDER_BUY or ORDER_SELL).   Note that it uses *my* Order Types (not the MQL:OP_BUY/OP_SELL ones!)
//|   b) a reason for opening the order (See "MyBasicMA" module for list of ENTRY_* types)
//|   c) an *Optional* 'Virtual Equity' parameter that allows you to pretend you have more equity than you actually have
//|
//| Returns: either the new Order Ticket #, or "-1" if a) you supplied an invalid OP_ code, or b) the order open failed for any reason
//+------------------------------------------------------------------+

int   PHOrderManagement2::openTradeAtMarket( const PH_FX_PAIRS eSymbol, const PH_ORDER_TYPES eOrderType, const PH_ENTRY_REASONS eReasonOpenType, const PHPercent& oPercentageOfEquityToRisk, const bool isFakeTrade = false )
{
   LLP(LOG_DEBUG)   //Set the 'Log File Prefix' and 'Log Threshold' for this function

   int  iOrderMagicID;
   int  iOrderTicketNumber = -1;



   //Step #1 - Calculate stop width
   // (NB This is is the 'width' of the move allowed, which is very different from the absolute 'StopLoss Price Level' which gets set later (and set to zero/disabled if the external flag has been set)
   //          Also note that I can't calculate the absolute Stop Loss Price Level until *after* the order has been placed and I take the final opening price (after slippage)
   // Note that the StopLoss Width doesn't take the spread into account per se.  That happens by choosing to subtracting it (for a long) from the Ask (not included), or Bid (included) price later.

   // HARDCODED TO 3 x ADTR (Average Daily True Range)
   PHTicks oTicks_StopLossWidth( eSymbol );    // e.g.  10-day average of ADTR, then mutiply by say, three
   myLogger.logINFO( StringFormat( "Stop Loss Algorithm: ADTR, Stop Loss width: %s", oTicks_StopLossWidth.toString() ) );
   /* ALTERNATIVE ALGOS...
   if( eInitialStopLossAlgorithm == STPLSSALGO_MAE ) {
      dTradeStoplossWidth_Price = dCalcStopLossWidth_MAE();  // e.g.  MAE of 0.02
      myLogger.logINFO( StringFormat( "Stop Loss Algorithm: MAE, Stop Loss width: %s", sFmtDdp( dTradeStoplossWidth_Price ) ) );
   */


   //Step #2a - Calculate Lot Size
   // HARDCODED TO ORIGINAL PERCENT-RISK MODEL FOR NOW
   PHLots oLotSize( eSymbol, oTicks_StopLossWidth, oPercentageOfEquityToRisk );
   double dLots = oLotSize.toNormalizedDouble();
   string sLots = oLotSize.toString();
   myLogger.logINFO(StringFormat( "Number of Lots (adjusted as per Max Permitted Risk per Trade): %s (given a Stop Loss Width of %s)", oLotSize.toString(), oTicks_StopLossWidth.toString() ) );


   //step #2b - Calculate Take Profit/Reward
   // <<<MISSING>>>



   //Step #3 - Validate Position Size (ensure it meets minimum broker size requirements)
   // Already normalized by PHLots object - it'll return *zero* (Lots) if invalid


   //By this step, 
   // We're given:          eOrderType
   // We *need* defined:    oTicks_StopLossWidth, oLotSize  
   // Are still underfined: iOrderMagicID, iOrderTicketNumber
   // No longer needed:     MaxPermittedRiskValue, RiskValueOf1Lot

   //Step #4 (Step#2a - 2nd time) *Re*calculate my risk now I've Position-Sized my order (i.e. a different Lot size that the 1st time)
   // (Aside: by taking the StopLoss Width without padding it out by the Spread, you're implicitly assuming that the Width will be subtracted (for a long) from the Ask, and not the Bid.)

   PHDollar oRiskValueForPosition( eSymbol, oTicks_StopLossWidth, oLotSize );   //(Calling a non-default PHDollar Constructor)
   myLogger.logINFO(StringFormat("With an adjusted Num of Allowed Lots: %s represents a potential Risk of: %s", oLotSize.toString(), oRiskValueForPosition.toString()  ) );


   //Step #5 - Determine whether I have sufficient margin to open the position?
   PHDollar oFreeMarginAfterOrder( 1 );   //initialize with a dummy value
            oFreeMarginAfterOrder.freeMarginAfterOrder( eSymbol, eOrderType, oLotSize );


   if ( oFreeMarginAfterOrder.toNormalizedDouble() < 0 ) {
      myLogger.logFATAL(StringFormat("I have INSUFFICIENT Margin to place a %s order of %s lots. Canceling Order!", EnumToString(eMyOrderTypeCode), oLotSize.toString() ));      //FATAL because I've run out of money!
      return(-1);
   } else {
      //Step #6 - initiate the Place Order loop...
      
      xxx
   }
      
      return 999;
};




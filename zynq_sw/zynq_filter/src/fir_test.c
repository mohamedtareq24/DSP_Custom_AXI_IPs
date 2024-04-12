/*
FPGA testbench for the FIR filter
noisy data is sent through the FIR and Filtered data is recived
Recived data is compared vs MATLAB outputted signal
this software uses the AXI stream FIFO driver in Polling mode  
*/
/***************************** Include Files *********************************/
#include "xparameters.h"
#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"

#include "my_fir_filter.h"

#ifdef XPAR_UARTNS550_0_BASEADDR
#include "xuartns550_l.h"       /* to use uartns550 */
#endif

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

#define TX_FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID
#define RX_FIFO_DEV_ID		XPAR_AXI_FIFO_1_DEVICE_ID

#define WORD_SIZE 4			/* Size of words in bytes */

#define MAX_PACKET_LEN 4

#define NO_OF_PACKETS 64

#define MAX_DATA_BUFFER_SIZE NO_OF_PACKETS*MAX_PACKET_LEN

#undef DEBUG

/************************** Function Prototypes ******************************/
#ifdef XPAR_UARTNS550_0_BASEADDR
static void Uart550_Setup(void);
#endif

int XLlFifoPollingExample(XLlFifo *InstancePtr, u16 DeviceId);
int TxSend(XLlFifo *InstancePtr, u32 *SourceAddr);
int RxReceive(XLlFifo *InstancePtr, u32 *DestinationAddr);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XLlFifo TXFifo ;
XLlFifo RXFifo ;

u32 SourceBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
u32 DestinationBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];

/*****************************************************************************/
/**
*
* Main function
*
* This function is the main entry of the Axi FIFO Polling test.
*
* @param	None
*
* @return
*		- XST_SUCCESS if tests pass
* 		- XST_FAILURE if fails.
*
* @note		None
*
******************************************************************************/
int main()
{
	xil_printf("--- Entering main() ---\n\r");
	int Status ;
	XLlFifo_Config *Config;

	//// init the filter & write then read & check the FIR coeffs 
	Status = 	my_fir_filter_init() ;
	if (Status!= XST_SUCCESS) {
		xil_printf("Filter init failure \n\r");
		return XST_FAILURE;
	}

/// init FIFOs
	// TX FIFO
	Config = XLlFfio_LookupConfig(TX_FIFO_DEV_ID);
	if (!Config) {
		xil_printf("No config found for Tx %d\r\n", TX_FIFO_DEV_ID);
		return XST_FAILURE;
	}
	Status = XLlFifo_CfgInitialize(&TXFifo, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		xil_printf("Tx Initialization failed\n\r");
		return Status;
	}

/// Resetting TX ISR
	Status = XLlFifo_Status(&TXFifo);
	XLlFifo_IntClear(&TXFifo,0xffffffff);
	Status = XLlFifo_Status(&TXFifo);
	if(Status != 0x0) {
		xil_printf("\n ERROR : Reset value of TX FIFO ISR0 : 0x%x\t"
					"Expected : 0x0\n\r",
					XLlFifo_Status(&TXFifo));
		return XST_FAILURE;
	}


	// RX FIFO
	Config = XLlFfio_LookupConfig(RX_FIFO_DEV_ID);
	if (!Config) {
		xil_printf("No config found for Rx %d\r\n", RX_FIFO_DEV_ID);
		return XST_FAILURE;
	}

	Status = XLlFifo_CfgInitialize(&RXFifo, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx Initialization failed\n\r");
		return Status;
	}

//Resetting RX ISR 
	Status = XLlFifo_Status(&RXFifo);
	XLlFifo_IntClear(&RXFifo,0xffffffff);
	Status = XLlFifo_Status(&RXFifo);
	if(Status != 0x0) {
		xil_printf("\n ERROR : Reset value of RX FIFO ISR0 : 0x%x\t"
					"Expected : 0x0\n\r",
					XLlFifo_Status(&RXFifo));
		return XST_FAILURE;
	}

//// Send noisy Data
// Generate the Noisy data , and set up the buffers source and destination
// for now lets go with some DATA from a LUT until I make something based on DDS 

	u32 noisy_data[] = {} 	;
	u32 expected_filtered_data[] = {}	;
	u32 filtered_data [] = {} ;

	Status = TxSend(&TXFifo, noisy_data);
	if (Status != XST_SUCCESS){
		xil_printf("Transmisson of Data failed\n\r");
		return XST_FAILURE;
	}

	Status = RxReceive(&RXFifo, filtered_data);
	if (Status != XST_SUCCESS){
		xil_printf("Receiving data failed");
		return XST_FAILURE;
	}

	int Error = 0;

	/* Compare the expected vs received */
	xil_printf(" Comparing data ...\n\r");
	for(int i=0 ; i<MAX_DATA_BUFFER_SIZE ; i++ ){
		if ( *(filtered_data + i) != *(expected_filtered_data + i) ){
			Error = 1;
			break;
		}
	}

	if (Error != 0){
		xil_printf("Filter Failed \n\r");
		return XST_FAILURE;
	}

	xil_printf("Successfully ran Axi Streaming FIFO Polling Example\n\r");
	xil_printf("--- Exiting main() ---\n\r");

	return XST_SUCCESS;
}

/**
*
* TxSend routine, It will send the requested amount of data at the
* specified addr.
*
* @param	InstancePtr is a pointer to the instance of the
*		XLlFifo component.
*
* @param	SourceAddr is the address where the FIFO stars writing
*
* @return
*		-XST_SUCCESS to indicate success
*		-XST_FAILURE to indicate failure
*
* @note		None
*
******************************************************************************/
int TxSend(XLlFifo *InstancePtr, u32  *SourceAddr)
{

	int i;
	int j;
	xil_printf(" Transmitting Data ... \r\n");

	/* Filling the buffer with data */
	for (i=0;i<MAX_DATA_BUFFER_SIZE;i++)
		*(SourceAddr + i) = 0;

	for(i=0 ; i < NO_OF_PACKETS ; i++){

		/* Writing into the FIFO Transmit Port Buffer */
		for (j=0 ; j < MAX_PACKET_LEN ; j++){
			if( XLlFifo_iTxVacancy(InstancePtr) ){
				XLlFifo_TxPutWord(InstancePtr,
					*(SourceAddr+(i*MAX_PACKET_LEN)+j));
			}
		}

	}

	/* Start Transmission by writing transmission length into the TLR */
	XLlFifo_iTxSetLen(InstancePtr, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));

	/* Check for Transmission completion */
	while( !(XLlFifo_IsTxDone(InstancePtr)) ){

	}

	/* Transmission Complete */
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* RxReceive routine.It will receive the data from the FIFO.
*
* @param	InstancePtr is a pointer to the instance of the
*		XLlFifo instance.
*
* @param	DestinationAddr is the address where to copy the received data.
*
* @return
*		-XST_SUCCESS to indicate success
*		-XST_FAILURE to indicate failure
*
* @note		None
*
******************************************************************************/
int RxReceive (XLlFifo *InstancePtr, u32* DestinationAddr)
{

	int i;
	int Status;
	u32 RxWord;
	static u32 ReceiveLength;

	xil_printf(" Receiving data ....\n\r");
	/* Read Recieve Length */
	ReceiveLength = (XLlFifo_iRxGetLen(InstancePtr))/WORD_SIZE;

	/* Start Receiving */
	for ( i=0; i < ReceiveLength; i++){
		RxWord = 0;
		RxWord = XLlFifo_RxGetWord(InstancePtr);

		if(XLlFifo_iRxOccupancy(InstancePtr)){
			RxWord = XLlFifo_RxGetWord(InstancePtr);
		}
		*(DestinationAddr+i) = RxWord;
	}

	Status = XLlFifo_IsRxDone(InstancePtr);
	if(Status != TRUE){
		xil_printf("Failing in receive complete ... \r\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

#ifdef XPAR_UARTNS550_0_BASEADDR
/*****************************************************************************/
/*
*
* Uart16550 setup routine, need to set baudrate to 9600 and data bits to 8
*
* @param	None
*
* @return	None
*
* @note		None
*
******************************************************************************/
static void Uart550_Setup(void)
{

	XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR,
			XPAR_XUARTNS550_CLOCK_HZ, 9600);

	XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR,
			XUN_LCR_8_DATA_BITS);
}
#endif

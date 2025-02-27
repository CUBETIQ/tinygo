// +build sam,atsamd51,feather_m4

package machine

import (
	"device/sam"
	"runtime/interrupt"
)

var (
	UART1  = &_UART1
	_UART1 = UART{
		Buffer: NewRingBuffer(),
		Bus:    sam.SERCOM5_USART_INT,
		SERCOM: 5,
	}

	UART2  = &_UART2
	_UART2 = UART{
		Buffer: NewRingBuffer(),
		Bus:    sam.SERCOM0_USART_INT,
		SERCOM: 0,
	}
)

func init() {
	UART1.Interrupt = interrupt.New(sam.IRQ_SERCOM5_2, _UART1.handleInterrupt)
	UART2.Interrupt = interrupt.New(sam.IRQ_SERCOM0_2, _UART2.handleInterrupt)
}

// I2C on the Feather M4.
var (
	I2C0 = &I2C{
		Bus:    sam.SERCOM2_I2CM,
		SERCOM: 2,
	}
)

// SPI on the Feather M4.
var (
	SPI0 = SPI{
		Bus:    sam.SERCOM1_SPIM,
		SERCOM: 1,
	}
)

__author__ = "Jordan Anderson"
__email__ = "jodog59@gmail.com"


from pynq import MMIO
from pynq import PL

class Register(object):
    """This class controls the Registers near the Video PR.

    Attributes
    ----------
    index : int
        The index of the register, starting from 0.
	offset : int
		The offset from the base register to the given register
    """
    _mmio = None

    def __init__(self, reg):
        """Create a new register object.
        
        Parameters
        ----------
        reg : int
            Index of the register, from 0 to 7.
        
        """
        if not reg in range(8):
            raise Value("Index for registers should be 0 - 7.")
            
        self.reg = reg
        self.reg_offset = reg * 4
        if Register._mmio is None:
            Register._mmio = MMIO(int(PL.ip_dict["SEG_Video_PR_0_S_AXI_reg"][0],16),32)

    def write(self, data):
        """Set the register value according to the input data.

        Parameters
        ----------
        data : int
            This parameter can be any 32 bit value
        
        """
        Register._mmio.write(self.reg_offset,data)

    def read(self):
        """Read the value in the register.

        Returns
        -------
        int
            A 32-bit value contained within the register
            
        """
        return Register._mmio.read(self.reg_offset)

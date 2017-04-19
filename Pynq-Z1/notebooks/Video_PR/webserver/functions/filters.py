from pynq import Overlay
from pynq import Bitstream_Part
from pynq.board import Register
from pynq.drivers.video import HDMI

class Filters:
    def __init__(self):
        self.width = 0
        self.hegiht = 0
        self.running = False
        self.hdmi_in = None
        self.hdmi_out = None


    def connect_HDMI(self):
        """
        Connect to HDMI
        """
        if not self.running:
            try:
                self.hdmi_in = HDMI('in',video_mode=4,init_timeout=2)
                print("HDMI in configured")
                self.width = self.hdmi_in.frame_width()
                self.height = self.hdmi_in.frame_height()
                self.hdmi_out = HDMI('out',video_mode=0,frame_list=self.hdmi_in.frame_list)
                print("HDMI out configured")

                self.hdmi_out.start()
                self.hdmi_in.start()
                self.running = True
                return True
            except Exception as e:
                self.running = False
                # print(e)
                return False
        print("Already Connected")
        return True

    def disconnect_HDMI(self):
        """
        Disconnect from HDMI
        """
        if self.running:
            self.running = False
            self.hdmi_out.stop()
            self.hdmi_in.stop()
            print("Ending Process")
            del self.hdmi_out
            del self.hdmi_in

    def load_full_bitstream(self,bitstream):
        try:
            Overlay(bitstream).download()
            print("Bitstream %s Loaded" % bitstream)
        except Exception as e:
            print("Could not find bitstream \"%s\"" % full_bitstream)
            return False
        return True

    def load_partial_bitstream(self,bitstream):
        try:
            Bitstream_Part(bitstream).download()
            print ("partial bitstream %s loaded" % bitstream)
        except Exception as e:
            print("Could not load bitstream")
            return False
        return True

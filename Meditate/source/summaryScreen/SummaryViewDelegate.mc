using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Lang;
using HrvAlgorithms.HrvTracking;

class SummaryViewDelegate extends ScreenPicker.ScreenPickerDelegate {
	private var mSummaryModel;
	private var mDiscardDanglingActivity;

	function initialize(summaryModel, isRespirationRateOn, discardDanglingActivity) {		
		me.mPagesCount = SummaryViewDelegate.getPagesCount(summaryModel.hrvTracking, isRespirationRateOn);
		setPageIndexes(summaryModel.hrvTracking, isRespirationRateOn);
		
        ScreenPickerDelegate.initialize(0, me.mPagesCount);
        me.mSummaryModel = summaryModel;
        me.mDiscardDanglingActivity = discardDanglingActivity;
        me.mSummaryLinesYOffset = App.getApp().getProperty("summaryLinesYOffset");
	}
		
	private var mSummaryLinesYOffset;
			
	private static function getPagesCount(hrvTracking, isRespirationRateOn) {		
		
		var pagesCount = 6;

		if (hrvTracking == HrvTracking.Off) {
			pagesCount -= 4;
		}
		else if (hrvTracking == HrvTracking.On) {
			pagesCount -= 2;
		}

		if (!isRespirationRateOn) {
			pagesCount -= 1;
		}

		return pagesCount;
	}
	
	private function setPageIndexes(hrvTracking, isRespirationRateOn) {	
		
		if (hrvTracking == HrvTracking.Off) {
			me.mStressPageIndex = InvalidPageIndex;
			me.mHrvRmssdPageIndex = InvalidPageIndex;
			me.mHrvSdrrPageIndex = InvalidPageIndex;
			me.mHrvPnnxPageIndex = InvalidPageIndex;

			if (isRespirationRateOn) {
				me.mRespirationPageIndex = 1;
			} else {
				me.mRespirationPageIndex = InvalidPageIndex;
			}

		}
		else {
			me.mStressPageIndex = 1;
			if (isRespirationRateOn) {
				me.mRespirationPageIndex = 2;
				me.mHrvRmssdPageIndex = 3;
			} else {
				me.mRespirationPageIndex = InvalidPageIndex;
				me.mHrvRmssdPageIndex = 2;
			}
				
			if (hrvTracking == HrvTracking.OnDetailed) {	
				me.mHrvPnnxPageIndex = me.mHrvRmssdPageIndex + 1;	
				me.mHrvSdrrPageIndex = me.mHrvRmssdPageIndex + 2;
			}
			else {
				me.mHrvPnnxPageIndex = InvalidPageIndex;
				me.mHrvSdrrPageIndex = InvalidPageIndex;
			}
		}
	}
	
	private var mPagesCount;
	
	private var mHrvRmssdPageIndex;
	private var mHrvSdrrPageIndex;
	private var mHrvPnnxPageIndex;
	private var mStressPageIndex;
	private var mRespirationPageIndex;
	
	private const InvalidPageIndex = -1;

	function onBack() {
		if (me.mDiscardDanglingActivity != null) {
			me.mDiscardDanglingActivity.invoke();
		}
		
		return false;
	}
	
	function createScreenPickerView() {
		var details;
		if (me.mSelectedPageIndex == 0) {
			details = me.createDetailsPageHr();
		} 
		else if (me.mSelectedPageIndex == me.mStressPageIndex) {
			details = me.createDetailsPageStress();
		}
		else if (me.mSelectedPageIndex == me.mRespirationPageIndex) {
			details = me.createDetailsPageRespiration();
		}
		else if (me.mSelectedPageIndex == mHrvRmssdPageIndex){
			details = me.createDetailsPageHrvRmssd();
		}
		else if (me.mSelectedPageIndex == mHrvPnnxPageIndex){
			details = me.createDetailsPageHrvPnnx();
		} 
		else if (me.mSelectedPageIndex == mHrvSdrrPageIndex){
			details = me.createDetailsPageHrvSdrr();
		} 
		else {
			details = me.createDetailsPageHr();
		}
		if (me.mPagesCount > 1) {
			return new ScreenPicker.ScreenPickerDetailsView(details);
		}
		else {
			return new ScreenPicker.ScreenPickerDetailsSinglePageView(details);
		}
	}	
				
	private function formatHr(hr) {
		return hr + " bpm";
	}
	
	private function createDetailsPageHr() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryHR);
        details.titleColor = Gfx.COLOR_BLACK;

        
        var timeIcon = new ScreenPicker.Icon({       
        	:font => StatusIconFonts.fontAwesomeFreeSolid,
        	:symbol => StatusIconFonts.Rez.Strings.faHourglassEnd,
        	:color=>Graphics.COLOR_BLACK  	
    	});
        details.detailLines[1].icon = timeIcon;
        details.detailLines[1].value.color = Gfx.COLOR_BLACK;
        details.detailLines[1].value.text = TimeFormatter.format(me.mSummaryModel.elapsedTime);
        
        var hrMinIcon = new ScreenPicker.Icon({       
        	:font => StatusIconFonts.fontMeditateIcons,
        	:symbol => StatusIconFonts.Rez.Strings.meditateFontHrMin,
        	:color=>Graphics.COLOR_RED   	
    	});     
        details.detailLines[2].icon = hrMinIcon;
        details.detailLines[2].value.color = Gfx.COLOR_BLACK;
        details.detailLines[2].value.text = me.formatHr(me.mSummaryModel.minHr);
                
        var hrAvgIcon = new ScreenPicker.Icon({       
        	:font => StatusIconFonts.fontMeditateIcons,
        	:symbol => StatusIconFonts.Rez.Strings.meditateFontHrAvg,
        	:color=>Graphics.COLOR_RED   	
    	});            
        details.detailLines[3].icon = hrAvgIcon;
        details.detailLines[3].value.color = Gfx.COLOR_BLACK;  
        details.detailLines[3].value.text = me.formatHr(me.mSummaryModel.avgHr);
        
        var hrMaxIcon = new ScreenPicker.Icon({       
        	:font => StatusIconFonts.fontMeditateIcons,
        	:symbol => StatusIconFonts.Rez.Strings.meditateFontHrMax,
        	:color=>Graphics.COLOR_RED   	
    	});              
        details.detailLines[4].icon = hrMaxIcon;    
        details.detailLines[4].value.color = Gfx.COLOR_BLACK; 
        details.detailLines[4].value.text = me.formatHr(me.mSummaryModel.maxHr);
		
        var hrIconsXPos = App.getApp().getProperty("summaryHrIconsXPos");
        var hrValueXPos = App.getApp().getProperty("summaryHrValueXPos");                
        details.setAllIconsXPos(hrIconsXPos);
        details.setAllValuesXPos(hrValueXPos);   
        details.setAllLinesYOffset(me.mSummaryLinesYOffset);
        
        return details;
	}	
		
	private function createDetailsPageStress() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryStress);
        details.titleColor = Gfx.COLOR_BLACK;

 		if (me.mSummaryModel.stressStart!=null && me.mSummaryModel.stressEnd!=null) {

				var lowStressIcon = new ScreenPicker.StressIcon({});
    			lowStressIcon.setLowStress();	      
        		details.detailLines[3].icon = lowStressIcon;  
				details.detailLines[3].value.color = Gfx.COLOR_BLACK;            
				details.detailLines[3].value.text = Lang.format(Ui.loadResource(Rez.Strings.SummaryStressStart), [me.mSummaryModel.stressStart.format("%d")]);

				lowStressIcon = new ScreenPicker.StressIcon({});
    			lowStressIcon.setLowStress();	      
        		details.detailLines[4].icon = lowStressIcon;  
				details.detailLines[4].value.color = Gfx.COLOR_BLACK;            
				details.detailLines[4].value.text = Lang.format(Ui.loadResource(Rez.Strings.SummaryStressEnd), [me.mSummaryModel.stressEnd.format("%d")]);
		}

    	var lowStressIcon = new ScreenPicker.StressIcon({});
    	lowStressIcon.setLowStress();	      
        details.detailLines[2].icon = lowStressIcon;  
        details.detailLines[2].value.color = Gfx.COLOR_BLACK;            
        details.detailLines[2].value.text = Lang.format("$1$ %", [me.mSummaryModel.stress]);
                 
        var summaryStressIconsXPos = App.getApp().getProperty("summaryStressIconsXPos");
        var summaryStressValueXPos = App.getApp().getProperty("summaryStressValueXPos");
        details.setAllIconsXPos(summaryStressIconsXPos);
        details.setAllValuesXPos(summaryStressValueXPos);   
        details.setAllLinesYOffset(me.mSummaryLinesYOffset);
        
        return details;
	}
	
	private function createDetailsPageRespiration() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryRespiration);
        details.titleColor = Gfx.COLOR_BLACK;

        
        var respirationIcon = new ScreenPicker.BreathIcon({});
        details.detailLines[2].icon = respirationIcon;
        details.detailLines[2].value.color = Gfx.COLOR_BLACK;
        details.detailLines[2].value.text = Ui.loadResource(Rez.Strings.SummaryRespirationMin) + me.mSummaryModel.minRr.toString();

		details.detailLines[3].icon = respirationIcon;
        details.detailLines[3].value.color = Gfx.COLOR_BLACK;
        details.detailLines[3].value.text = Ui.loadResource(Rez.Strings.SummaryRespirationAvg) + me.mSummaryModel.avgRr.toString();

		details.detailLines[4].icon = respirationIcon;
        details.detailLines[4].value.color = Gfx.COLOR_BLACK;
        details.detailLines[4].value.text = Ui.loadResource(Rez.Strings.SummaryRespirationMax) + me.mSummaryModel.maxRr.toString();
        		
        var hrIconsXPos = App.getApp().getProperty("summaryHrIconsXPos");
        var hrValueXPos = App.getApp().getProperty("summaryHrValueXPos");                
        details.setAllIconsXPos(hrIconsXPos);
        details.setAllValuesXPos(hrValueXPos);   
        details.setAllLinesYOffset(me.mSummaryLinesYOffset + 10);
        
        return details;
	}	

	private function createDetailsPageHrvRmssd() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryHRVRMSSD);
        details.titleColor = Gfx.COLOR_BLACK;
                             
        details.detailLines[3].icon = new ScreenPicker.HrvIcon({});              
        details.detailLines[3].value.color = Gfx.COLOR_BLACK;
        details.detailLines[3].value.text = Lang.format("$1$ ms", [me.mSummaryModel.hrvRmssd]);
                 
        var hrvIconsXPos = App.getApp().getProperty("summaryHrvIconsXPos");
        var hrvValueXPos = App.getApp().getProperty("summaryHrvValueXPos");
        details.setAllIconsXPos(hrvIconsXPos);
        details.setAllValuesXPos(hrvValueXPos); 
        details.setAllLinesYOffset(me.mSummaryLinesYOffset);
        
        return details;
	}	
	
	private function createDetailsPageHrvPnnx() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryHRVpNNx);
        details.titleColor = Gfx.COLOR_BLACK;
                            
        var hrvIcon = new ScreenPicker.HrvIcon({});            
        details.detailLines[2].icon = hrvIcon;      
        details.detailLines[2].value.color = Gfx.COLOR_BLACK;        
        details.detailLines[2].value.text = "pNN20";
        
        details.detailLines[3].value.color = Gfx.COLOR_BLACK;
        details.detailLines[3].value.text = Lang.format("$1$ %", [me.mSummaryModel.hrvPnn20]);
        
    	details.detailLines[4].icon = hrvIcon;
    	details.detailLines[4].value.color = Gfx.COLOR_BLACK;
        details.detailLines[4].value.text = "pNN50";
        details.detailLines[5].value.color = Gfx.COLOR_BLACK;
        details.detailLines[5].value.text = Lang.format("$1$ %", [me.mSummaryModel.hrvPnn50]);  
         
        var hrvIconsXPos = App.getApp().getProperty("summaryHrvIconsXPos");
        var hrvValueXPos = App.getApp().getProperty("summaryHrvValueXPos");
        details.setAllIconsXPos(hrvIconsXPos);
        details.setAllValuesXPos(hrvValueXPos); 
        details.setAllLinesYOffset(me.mSummaryLinesYOffset);
        
        return details;
	}	
	
	private function createDetailsPageHrvSdrr() {
		var details = new ScreenPicker.DetailsModel();
		details.color = Gfx.COLOR_BLACK;
        details.backgroundColor = Gfx.COLOR_WHITE;
        details.title = Ui.loadResource(Rez.Strings.SummaryHRVSDRR);
        details.titleColor = Gfx.COLOR_BLACK;
                        
        var hrvIcon = new ScreenPicker.HrvIcon({});            
        details.detailLines[2].icon = hrvIcon;      
        details.detailLines[2].value.color = Gfx.COLOR_BLACK;        
        details.detailLines[2].value.text = Ui.loadResource(Rez.Strings.SummaryHRVRMSSDFirst5min);
        
        details.detailLines[3].value.color = Gfx.COLOR_BLACK;
        details.detailLines[3].value.text = Lang.format("$1$ ms", [me.mSummaryModel.hrvFirst5Min]);
        
    	details.detailLines[4].icon = hrvIcon;
    	details.detailLines[4].value.color = Gfx.COLOR_BLACK;
        details.detailLines[4].value.text = Ui.loadResource(Rez.Strings.SummaryHRVRMSSDLast5min);
        details.detailLines[5].value.color = Gfx.COLOR_BLACK;
        details.detailLines[5].value.text = Lang.format("$1$ ms", [me.mSummaryModel.hrvLast5Min]);  
         
        var hrvIconsXPos = App.getApp().getProperty("summaryHrvIconsXPos");
        var hrvValueXPos = App.getApp().getProperty("summaryHrvValueXPos");
        details.setAllIconsXPos(hrvIconsXPos);
        details.setAllValuesXPos(hrvValueXPos); 
        details.setAllLinesYOffset(me.mSummaryLinesYOffset);
        
        return details;
	}	
}
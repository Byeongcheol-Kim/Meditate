using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Application as App;

class DetailsViewRenderer {
	private const InitialTextPosY = 30;
	private const TextPosYOffset = 30;
	private const TitlePosY = 20;
	private const IconX = 30;
	
	private var mDetailsModel;
	
	function initialize(detailsModel) {
		me.mDetailsModel = detailsModel;
		me.progressBarWidth = App.getApp().getProperty("progressBarWidth");
	}
	
	function renderBackgroundColor(dc) {				        
        dc.setColor(Gfx.COLOR_TRANSPARENT, me.mDetailsModel.backgroundColor);        
        dc.clear();        
    }
    
    function renderDetailsView(dc) {
        dc.setColor(me.mDetailsModel.titleColor, Gfx.COLOR_TRANSPARENT); 
       	me.displayTitle(dc, me.mDetailsModel.title);
		
		for (var lineNumber = 1; lineNumber <= me.mDetailsModel.detailLines.size(); lineNumber++) {
        	dc.setColor(me.mDetailsModel.color, Gfx.COLOR_TRANSPARENT); 
			var line = me.mDetailsModel.detailLines[lineNumber];
			if (line.icon != null) {
				me.displayIcon(dc, lineNumber, line.icon, line.iconOffset, line.yLineOffset);
			}
			if (line.value instanceof TextLine) {
       			me.displayText(dc, lineNumber, line.value.text, line.valueOffset, line.yLineOffset);  
       		}
   			else if	(line.value instanceof PercentageHighlightLine) {
   				me.drawPercentageHighlightLine(dc, lineNumber, line.value.getHighlights(), line.value.backgroundColor, line.valueOffset);
   			}
       	}       
    }
    
    private var progressBarWidth;
    private const ProgressBarHeight = 16;
    
    private function drawPercentageHighlightLine(dc, lineNumber, highlights, backgroundColor, valueOffset) {
    	var valuePosXOffset = dc.getWidth() / 3.4 + valueOffset;
    	var posY = me.getLinePosY(lineNumber) + 10;
		
		dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
		dc.fillRectangle(valuePosXOffset, posY, progressBarWidth, ProgressBarHeight);   
		
		var highlightWidth = 0.03 * progressBarWidth;		
    	for (var i = 0; i < highlights.size(); i++) {
    		var highlight = highlights[i];
    		var valuePosX = valuePosXOffset + highlight.progressPercentage * progressBarWidth;
    		dc.setColor(highlight.color, Gfx.COLOR_TRANSPARENT);
    		dc.fillRectangle(valuePosX, posY, highlightWidth, ProgressBarHeight);    		
    	}
    }
    
    private function displayTitle(dc, title) {
        var textX = dc.getWidth() / 2;	
        dc.drawText(textX, TitlePosY, Gfx.FONT_SYSTEM_MEDIUM, title, Gfx.TEXT_JUSTIFY_CENTER);
    }	
    
    private function getLinePosY(lineNumber) {
    	return lineNumber * TextPosYOffset + InitialTextPosY;
    }
        	
	private function displayIcon(dc, lineNumber, drawableId, iconOffset, yLineOffset) {
        var posX = IconX + iconOffset;
        var posY = getLinePosY(lineNumber) + yLineOffset;
        
		var bitmap = new Ui.Bitmap({
	         :rezId=>drawableId,
	         :locX=>posX,
	         :locY=>posY
     	});
     	bitmap.draw(dc);
	}
    
    private function displayText(dc, lineNumber, text, valueOffset, yLineOffset) {   
        var textX = dc.getWidth() / 3.4 + valueOffset;
        var posY = getLinePosY(lineNumber) + yLineOffset;		
        
        dc.drawText(textX, posY, Gfx.FONT_SYSTEM_SMALL, text, Gfx.TEXT_JUSTIFY_LEFT);
    }    
}
function FigureIntoWord(actx_word_p)
	% Capture current figure/model into clipboard:
	print(gcf,'-dbitmap');
	% Find end of document and make it the insertion point:
	end_of_doc = get(actx_word_p.activedocument.content,'end');
	set(actx_word_p.application.selection,'Start',end_of_doc);
	set(actx_word_p.application.selection,'End',end_of_doc);
	% Paste the contents of the Clipboard:
    %also works Paste(ActXWord.Selection)

% 	invoke(actx_word_p.Selection,'Paste');

    actx_word_p.selection.PasteSpecial(0,0,1,0,3);
    % Modify shape size (72 points in one inch) and convert to
    % InlineShape. Move cursor one position to the right for the next action. 
    actx_word_p.selection.ShapeRange.Width = 320;     % width = 1inch
    actx_word_p.selection.Shaperange.ConvertToInlineShape;
    actx_word_p.selection.Start = actx_word_p.selection.Start+1;
    actx_word_p.selection.End = actx_word_p.selection.End+1;
    actx_word_p.Selection.TypeParagraph; %enter    
return
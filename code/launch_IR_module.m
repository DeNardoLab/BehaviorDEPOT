function launch_IR_module()
x = 200;
y = 200;
width = 400;
height = 400;
fig = uifigure('Name', 'inter-rater module params', 'Position', [x y width height]);
lbl = uilabel(fig);

txt = ["Select the kinds of interrater", "plots you want to generate"];
lbl.Text = txt;
% [left bottom width height] -- left and bottom, relative to parent
lbl.Position = [10 height-75  180 60];
%lbl.WordWrap = 'on';   % WordWrap only works in 2020b

cb.dis = uicheckbox(fig, 'Text', 'Disagreement', 'Value', 0, 'Position', [10 height-100 180 25]);
cb.peragree = uicheckbox(fig, 'Text', 'Percent Agreement', 'Value', 0, 'Position', [10 height-125 180 25]);
cb.peroverlap = uicheckbox(fig, 'Text', 'Percent Overlap', 'Value', 0, 'Position', [10 height-150 180 25]);
cb.perf = uicheckbox(fig, 'Text', 'Performance', 'Value', 0, 'Position', [10 height-175 180 25]);
cb.visann = uicheckbox(fig, 'Text', 'Visualize Annotations', 'Value', 0, 'Position', [10 height-200 180 25]);
txt = ["Restrict analysis to","subset of rater files"];
cb.ratersubset = uicheckbox(fig, 'Text', txt, 'Value', 0, 'Position', [10 height-225 180 25]);

start_btn = uibutton(fig, 'Text', 'Start', 'Position', [10 10 70 25], 'ButtonPushedFcn', @(start_btn,event) plotPrefs_launchIR(cb));
cancel_btn = uibutton(fig, 'Text', 'Cancel', 'Position', [100 10 70 25], 'ButtonPushedFcn', @(cancel_btn,event) close(fig));

end
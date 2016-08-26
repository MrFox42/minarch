-- Minimap Functions
function MinArch:MinimapButtonReposition()
	MinArchMinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(MinArchOptions.MinimapPos)),(80*sin(MinArchOptions.MinimapPos))-52)
end

-- Drag the minimap button
function MinArch:MinimapButtonDraggingFrameOnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	MinArchOptions.MinimapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	MinArch:MinimapButtonReposition() -- move the button
end

-- Hide/Show the minimap button
function MinArch:MinimapButtonOnClick(self, button, down)
	if (button == "LeftButton") then
		if (MinArchMain:IsVisible()) then
			MinArch:HideMain();
		else
			MinArch:ShowMain();
			MinArchHideNext = false;
		end
	elseif (button == "RightButton") then
		InterfaceOptionsFrame_OpenToCategory(MinArchOptionPanel);
	end
end

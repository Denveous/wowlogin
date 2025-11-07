FADE_IN_TIME = 2;
DEFAULT_TOOLTIP_COLOR = {0.8, 0.8, 0.8, 0.09, 0.09, 0.09};
MAX_PIN_LENGTH = 10;
autoLogin = false;
autoLoginCounter = 0

GlueDialogTypes["REMEMBER_PASSWORD"] = {
	text = "Do you really want to save your Password?",
	button1 = YES, 
	button2 = NO,
	OnAccept = function ()
	end,
	OnCancel = function()
		AccountLoginSavePassword:SetChecked(0);
	end,
}

function AccountLogin_SetupAutoLogin()
	autoLoginCounter = 0
	AccountLogin:SetScript("OnUpdate", function(self)
		autoLoginCounter = autoLoginCounter + 1
		if autoLoginCounter >= 120 then -- 120 frames 60*2 -- 2 seconds
			AccountLogin_Login()
			PlaySound("igMainMenuOptionCheckBoxOn")
			this:SetScript("OnUpdate", nil)
		end
	end)
end

function AccountLogin_OnLoad()
	this:SetSequence(0);
	this:SetCamera(0);

	this:RegisterEvent("SHOW_SERVER_ALERT");
	this:RegisterEvent("SHOW_SURVEY_NOTIFICATION");

	local versionType, buildType, version, internalVersion, date = GetBuildInfo();
	AccountLoginVersion:SetText(format(TEXT(VERSION_TEMPLATE), versionType, version, internalVersion, buildType, date));

	-- Color edit box backdrops
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	AccountLoginAccountEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	AccountLoginAccountEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	AccountLoginPasswordEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	AccountLoginPasswordEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	VirtualKeypadText:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	VirtualKeypadText:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
end

 function string_explode(str, div)
       local o = {}
       while true do
               local pos1,pos2 = strfind(str, div)
               if not pos1 then
                       o[getn(o)+1] = str
                       break
               end
               o[getn(o)+1] = strsub(str,1,pos1-1)
               str = strsub(str,pos2+1)
       end
       return o
 end

function AccountLogin_OnShow()
	local t = string_explode(GetSavedAccountName(), "#&|&#")
	local accountName = t[1] or "";
	local password = t[2] or "";
	autoLogin = t[3] == "1";

	AccountLoginAutoLogin:SetChecked(autoLogin)

	CurrentGlueMusic = "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3";

	AccountLoginAccountEdit:SetText(accountName or "");
	AccountLoginPasswordEdit:SetText(password or "");

	if (autoLogin) then
	  AccountLogin_SetupAutoLogin()
	end

	AcceptTOS();
        AcceptEULA();

	local serverName = GetServerName();
	if(serverName) then
		AccountLoginRealmName:SetText(serverName);
	else
		AccountLoginRealmName:Hide()
	end

	if ( accountName == "" ) then
		AccountLogin_FocusAccountName();
	elseif ( password == "" ) then
		AccountLogin_FocusPassword();
	else

	end
end

function AccountLogin_FocusPassword()
	AccountLoginPasswordEdit:SetFocus();
end

function AccountLogin_FocusAccountName()
	AccountLoginAccountEdit:SetFocus();
end

function AccountLogin_OnChar()
end

function AccountLogin_OnKeyDown()
	if ( autoLoginCounter and autoLoginCounter > 0 ) then -- any keypress cancel instead of just esc
		PlaySound("igMainMenuOptionCheckBoxOff");
		autoLoginCounter = 0;
		AccountLogin:SetScript("OnUpdate", nil);
	end
	if ( arg1 == "ESCAPE" ) then
		if ( ConnectionHelpFrame:IsVisible() ) then
			ConnectionHelpFrame:Hide();
			AccountLoginUI:Show();
		elseif ( SurveyNotificationFrame:IsVisible() ) then
			-- do nothing
		else
			AccountLogin_Exit();
		end
		
	elseif ( arg1 == "ENTER" ) then
		if ( not TOSAccepted() ) then
			return;
		elseif ( TOSFrame:IsVisible() or ConnectionHelpFrame:IsVisible() ) then
			return;
		elseif ( SurveyNotificationFrame:IsVisible() ) then
			AccountLogin_SurveyNotificationDone(1);
		end
		AccountLogin_Login();
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AccountLogin_OnEvent(event)
	if ( event == "SHOW_SERVER_ALERT" ) then
		ServerAlertText:SetText(arg1);
		ServerAlertScrollFrame:UpdateScrollChildRect();
		ServerAlertFrame:Show();
	elseif ( event == "SHOW_SURVEY_NOTIFICATION" ) then
		AccountLogin_ShowSurveyNotification();
	end
end

function AccountLogin_Login()
	PlaySound("gsLogin");
	DefaultServerLogin(AccountLoginAccountEdit:GetText(), AccountLoginPasswordEdit:GetText());
	
	if ( AccountLoginSaveAccountName:GetChecked() ) then
		if ( AccountLoginSavePassword:GetChecked() ) then
			SetSavedAccountName(AccountLoginAccountEdit:GetText().."#&|&#"..AccountLoginPasswordEdit:GetText().."#&|&#"..(AccountLoginAutoLogin:GetChecked() and "1" or "0"));
		else
			SetSavedAccountName(AccountLoginAccountEdit:GetText());
		end
	else
		SetSavedAccountName("");
		SetUsesToken(false);
	end
end

function AccountLogin_Turtle_Armory_Website()
	PlaySound("gsLoginNewAccount");
	LaunchURL(TURTLE_ARMORY_WEBSITE);
end

function AccountLogin_Turtle_Website()
	PlaySound("gsLoginNewAccount");
	LaunchURL(AUTH_TURTLE_WEBSITE);
end

function AccountLogin_Turtle_Knowledge_Database()
	PlaySound("gsLoginNewAccount");
	LaunchURL(TURTLE_KNOWLEDGE_DATABASE_WEBSITE);
end

function AccountLogin_Turtle_Community_Forum()
	PlaySound("gsLoginNewAccount");
	LaunchURL(TURTLE_COMMUNITY_FORUM_WEBSITE);
end

function AccountLogin_Turtle_Discord()
	PlaySound("gsLoginNewAccount");
	LaunchURL(TURTLE_DISCORD_WEBSITE);
end

function AccountLogin_Credits()
	if ( not GlueDialog:IsVisible() ) then
		PlaySound("gsTitleCredits");
		SetGlueScreen("credits");
	end
end

function AccountLogin_Cinematics()
	if ( not GlueDialog:IsVisible() ) then
		PlaySound("gsTitleIntroMovie");
		SetGlueScreen("movie");
	end
end

function AccountLogin_Options()
	PlaySound("gsTitleOptions");
end

function AccountLogin_Exit()
	PlaySound("gsTitleQuit");
	QuitGame();
end

function AccountLogin_ShowSurveyNotification()
	GlueDialog:Hide();
	AccountLoginUI:Hide();
	SurveyNotificationAccept:Enable();
	SurveyNotificationDecline:Enable();
	SurveyNotificationFrame:Show();
end

function AccountLogin_SurveyNotificationDone(accepted)
	SurveyNotificationFrame:Hide();
	SurveyNotificationAccept:Disable();
	SurveyNotificationDecline:Disable();
	SurveyNotificationDone(accepted);
	AccountLoginUI:Show();
end

-- Virtual keypad functions
local buttonText = {}
function VirtualKeypadFrame_OnEvent(event)
	if ( event == "PLAYER_ENTER_PIN" ) then
		for i=1, 10 do
			buttonText[i] = getglobal("arg"..i)
		end
	end
	-- Randomize location to prevent hacking (yeah right)
	local xPadding = 5;
	local yPadding = 10;
	local xPos = random(xPadding, GlueParent:GetWidth()-VirtualKeypadFrame:GetWidth()-xPadding);
	local yPos = random(yPadding, GlueParent:GetHeight()-VirtualKeypadFrame:GetHeight()-yPadding);
	--VirtualKeypadFrame:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", xPos, -yPos);
	
	VirtualKeypadFrame:Show();
	VirtualKeypad_UpdateButtons();
end

function VirtualKeypadButton_OnClick()
	local text = VirtualKeypadText:GetText();
	if ( not text ) then
		text = "";
	end
	VirtualKeypadFrame.PIN = VirtualKeypadFrame.PIN..this:GetID();
	VirtualKeypadText:SetText(VirtualKeypadFrame.PIN);
	VirtualKeypad_UpdateButtons();
end

function VirtualKeypadOkayButton_OnClick()
	local PIN = VirtualKeypadText:GetNumber();
	local numNumbers = strlen(PIN);
	if numNumbers < 6 then return end
	local pinNumber = {};
	for i=1, MAX_PIN_LENGTH do
		if ( i <= numNumbers ) then
			pinNumber[i] = nil;
			for j=1, 10 do
				if tonumber(buttonText[j]) == tonumber(strsub(PIN,i,i)) then
					pinNumber[i] = j-1;
				end
			end
		else
			pinNumber[i] = nil;
		end
	end
	PINEntered(pinNumber[1] , pinNumber[2], pinNumber[3], pinNumber[4], pinNumber[5], pinNumber[6], pinNumber[7], pinNumber[8], pinNumber[9], pinNumber[10]);
	VirtualKeypadFrame:Hide();
end

function VirtualKeypad_UpdateButtons()
end

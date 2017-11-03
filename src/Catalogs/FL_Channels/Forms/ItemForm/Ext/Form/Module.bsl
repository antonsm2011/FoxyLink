﻿// This file is part of FoxyLink.
// Copyright © 2016-2017 Petro Bazeliuk.
// 
// This program is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Affero General Public License as 
// published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License 
// along with FoxyLink. If not, see <http://www.gnu.org/licenses/agpl-3.0>.

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
    
    If IsBlankString(Object.BasicChannelGuid) Then
        For Each Channel In Catalogs.FL_Channels.AvailableChannels() Do
            FillPropertyValues(Items.BasicChannelGuid.ChoiceList.Add(), Channel);    
        EndDo;
        Items.HeaderPagesChannel.CurrentPage = Items.HeaderPageSelectChannel;
        Items.HeaderGroupLeft.Visible = False;
    Else
        LoadBasicChannelInfo();    
    EndIf;
    
EndProcedure // OnCreateAtServer() 

#EndRegion // FormEventHandlers

#Region FormItemsEventHandlers

&AtClient
Procedure BasicChannelGuidOnChange(Item)
    
    If Not IsBlankString(Object.BasicChannelGuid) Then
        LoadBasicChannelInfo();   
    EndIf;
    
EndProcedure // BasicChannelGuidOnChange()

&AtClient
Procedure ChannelStandardClick(Item, StandardProcessing)
    
    StandardProcessing = False;
    BeginRunningApplication(New NotifyDescription(
        "DoAfterBeginRunningApplication", ThisObject), 
        ChannelStandardLink(ChannelProcessorName, Object.BasicChannelGuid));
    
EndProcedure // ChannelStandardClick()

#EndRegion // FormItemsEventHandlers

#Region FormCommandHandlers

&AtClient
Procedure ChannelForm(Command)
    
    ChannelParameters = ChannelParameters(ChannelProcessorName, 
        Object.BasicChannelGuid, "ChannelForm");
    ChannelParameters.Insert("ChannelData", Object.ChannelData);
    ChannelParameters.Insert("EncryptedData", Object.EncryptedData);
    
    OpenForm(ChannelParameters.FormName, 
        ChannelParameters, 
        ThisObject,
        New UUID, 
        , 
        , 
        //New NotifyDescription("DoAfterCloseConnectionForm", ThisObject, 
        //    ChannelParameters)
        , 
        FormWindowOpeningMode.LockOwnerWindow);
          
EndProcedure // ChannelForm()

&AtClient
Procedure Connect(Command)
    
    ChannelParameters = ChannelParameters(ChannelProcessorName, 
        Object.BasicChannelGuid);
    OpenForm(ChannelParameters.FormName, 
        ChannelParameters, 
        ThisObject,
        New UUID, 
        , 
        , 
        New NotifyDescription("DoAfterCloseConnectionForm", ThisObject, 
            ChannelParameters), 
        FormWindowOpeningMode.LockOwnerWindow);
    
EndProcedure // Connect()

&AtClient
Procedure Disconnect(Command)
    
    If Modified = False Then
        
        ShowQueryBox(New NotifyDescription("DoAfterChannelDisconnect", ThisObject),
            NStr("en = 'Invalidate channel connection?';
                 |ru = 'Отключить соединение с каналом?'"),
            QuestionDialogMode.YesNo, , DialogReturnCode.No);
        
    Else
        
        FL_CommonUseClientServer.NotifyUser(NStr(
            "en = 'There are unsaved changes, they must be saved.'; 
            |ru = 'Имеются несохраненные изменения, их необходимо сохранить.'"));        
        
    EndIf;
    
EndProcedure // Disconnect()

#EndRegion // FormCommandHandlers

#Region ServiceProceduresAndFunctions

// Only for internal use.
//
&AtClient
Procedure DoAfterBeginRunningApplication(CodeReturn, AdditionalParameters) Export
    
    // TODO: Some checks   
    
EndProcedure // DoAfterBeginRunningApplication()

// Only for internal use.
//
&AtClient
Procedure DoAfterCloseConnectionForm(ClosureResult, AdditionalParameters) Export
    
    If ClosureResult <> Undefined Then
        
        If TypeOf(ClosureResult) = Type("FormDataStructure") Then
            
            Modified = True;
            Object.Connected = True;
            
            If ClosureResult.Property("ChannelData") And
                TypeOf(ClosureResult.ChannelData) = Type("FormDataCollection") Then
                For Each Item In ClosureResult.ChannelData Do
                    NewData = Object.ChannelData.Add();        
                    FillPropertyValues(NewData, Item);
                EndDo;     
            EndIf;
            
            If ClosureResult.Property("EncryptedData") And
                TypeOf(ClosureResult.EncryptedData) = Type("FormDataCollection") Then
                For Each Item In ClosureResult.EncryptedData Do
                    NewData = Object.EncryptedData.Add();        
                    FillPropertyValues(NewData, Item);
                EndDo;    
            EndIf;
            
            LoadBasicChannelInfo();
            
        EndIf;
 
    EndIf;
    
EndProcedure // DoAfterCloseConnectionForm()

// Only for internal use.
//
&AtClient
Procedure DoAfterChannelDisconnect(QuestionResult, AdditionalParameters) Export 

    If QuestionResult = DialogReturnCode.Yes Then
        DisconnectChannel(ChannelProcessorName, Object.BasicChannelGuid);        
    EndIf;
    
EndProcedure // DoAfterChannelDisconnect()







// Fills basic channel info.
//
&AtServer
Procedure LoadBasicChannelInfo()

    Items.HeaderGroupLeft.Visible = True;
    Items.HeaderPagesChannel.CurrentPage = Items.HeaderPageBasicChannel;
    ChannelProcessor = Catalogs.FL_Channels.NewChannelProcessor(
        ChannelProcessorName, Object.BasicChannelGuid);
        
    ChannelName = StrTemplate("%1 (%2)", ChannelProcessor.ChannelFullName(),
        ChannelProcessor.ChannelShortName());    
    ChannelStandard = ChannelProcessor.ChannelStandard();      
    ChannelPluginVersion = ChannelProcessor.Version();
    
    If ChannelProcessor.PreAuthorizationRequired() Then
        Items.Connect.Visible = Not Object.Connected;
        Items.ChannelForm.Visible = Object.Connected;
        Items.Disconnect.Visible = Object.Connected;
    EndIf;
     
EndProcedure // LoadBasicChannelInfo()

// Invalidates channel connection.
//
&AtServer
Procedure DisconnectChannel(ChannelProcessorName, Val LibraryGuid)
    
    ChannelProcessor = Catalogs.FL_Channels.NewChannelProcessor(
        ChannelProcessorName, LibraryGuid);
    ChannelProcessor.ChannelData.Load(Object.ChannelData.Unload());
    ChannelProcessor.EncryptedData.Load(Object.EncryptedData.Unload());
    ChannelProcessor.Disconnect(Undefined);
    
    Object.Connected = False;
    Object.ChannelData.Clear();
    Object.EncryptedData.Clear();
    
    Write();
    
    LoadBasicChannelInfo();
      
EndProcedure // DisconnectChannel()



// Only for internal use.
//
&AtServerNoContext
Function ChannelParameters(ChannelProcessorName, Val LibraryGuid, 
    Val FormName = "ConnectionForm")
    
    Return Catalogs.FL_Channels.NewChannelParameters(
        ChannelProcessorName, LibraryGuid, FormName);      
 
EndFunction // ChannelParameters() 

// Returns link to the channel document from the Internet.
//
&AtServerNoContext
Function ChannelStandardLink(ChannelProcessorName, Val LibraryGuid) 
    
    ChannelProcessor = Catalogs.FL_Channels.NewChannelProcessor(
        ChannelProcessorName, LibraryGuid);     
    Return ChannelProcessor.ChannelStandardLink();
    
EndFunction // ChannelStandardLink()

#EndRegion // ServiceProceduresAndFunctions   
    
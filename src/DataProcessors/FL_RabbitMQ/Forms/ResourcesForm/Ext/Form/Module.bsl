﻿////////////////////////////////////////////////////////////////////////////////
// This file is part of FoxyLink.
// Copyright © 2016-2019 Petro Bazeliuk.
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
//
////////////////////////////////////////////////////////////////////////////////

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
    
    If Parameters.Property("AutoTest") Then
        Return;
    EndIf;

    PropTimestamp = True;
    PropDeliveryMode = "non-persistent";
    
    FL_InteriorUse.FillAppEndpointResourcesFormData(ThisObject, Parameters);
    
    If IsBlankString(PayloadEncoding) Then
        PayloadEncoding = "string";
    EndIf;
         
EndProcedure // OnCreateAtServer()

#EndRegion // FormEventHandlers

#Region FormCommandHandlers

&AtClient
Procedure SaveAndClose(Command)
            
    If IsBlankString(RoutingKey) Then
        FL_CommonUseClientServer.NotifyUser(NStr("
                |en='Field {Routing key} must be filled.';
                |ru='Поле {Ключ маршрутизации} должно быть заполнено.';
                |uk='Поле {Ключ маршрутизації} повинно бути заповненим.';
                |en_CA='Field {Routing key} must be filled.'"), , 
            "RoutingKey");
        Return;  
    EndIf;
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "Path", "PublishToExchange");
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "Exchange", Exchange);

    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "VirtualHost", VirtualHost);
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "RoutingKey", RoutingKey);
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PayloadEncoding", PayloadEncoding);

    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PropDeliveryMode", PropDeliveryMode);
     
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PropExpiration", PropExpiration);
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PropPriority", PropPriority);
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PropType", PropType);
    
    FL_EncryptionClientServer.AddFieldValue(Object.ChannelResources, 
        "PropUserId", PropUserId);
        
    Close(Object);
    
EndProcedure // SaveAndClose()

#EndRegion // FormCommandHandlers
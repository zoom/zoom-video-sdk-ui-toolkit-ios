//
//  UIToolkitError.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation

/// Enumeration of all the UI toolkit errors.
public enum UIToolkitError: Int, CaseIterable {
    // Note: DocC auto sort alphabetically for Enum. Can't seem to find a way to sort by Int value
    // TODO: Find to not sort it
    
    // Authentication Related
    /// Authentication error, no key or secret found.
    case EmptyKeyOrSecret = 1000
    /// Authentication error, wrong key or secret.
    case InvalidKeyOrSecret
    
    // Join Session Related
    /// Join session error, no tpc (topic) name.
    case EmptySessionName = 2000
    /// Join session error, no session token.
    case EmptySessionToken
    /// Join Session error, no session name within token.
    case TokenEmptySessionName
    /// Join session error, no session user name.
    case EmptyUsername
    /// Join session error, invalid session name.
    case InvalidSessionName
    /// Join session error, invalid session password.
    case WrongPassword
    /// Join session error, invalid session token.
    case InvalidSessionToken
    /// Join session error, missing session password.
    case MissingPassword
    /// Join Session error, session name too long.
    case SessionNameTooLong
    /// Join session token error, mismatched session name.
    case TokenMismatchedSessionName
    /// Join session token error, user identity too long.
    case TokenUserIdentityTooLong
    /// Join session error, invalid parameter.
    case InvalidParam
    /// Join session error, failed to join session.
    case JoinFailed
    
    // In Session Related
    /// Session error, no microphone permission.
    case NoMicrophonePermission = 3000
    /// Session error, no camera permission.
    case NoCameraPermission
    /// Session error, failed to leave session.
    case LeaveSessionFailed
    /// Session error, failed to mute mic.
    case MuteMicFailed
    /// Session error, failed to unmute mic.
    case UnmuteMicFailed
    /// Session error, failed to start video.
    case StartCameraFailed
    /// Session error, failed to stop video.
    case StopCameraFailed
    /// Session error, failed to send group message.
    case SendGroupMessageFailed
    /// Session error, failed to send private message.
    case SendPrivateMessageFailed
    /// Session error, failed to enable group and private chat.
    case EnableGroupAndPrivateChatFailed
    /// Session error, failed to disable group and private chat.
    case DisableGroupAndPrivateChatFailed
    /// Session error, failed to change virtual background.
    case ChangeVirtualBackgroundFailed
    /// Session error, failed to change local user's  name.
    case ChangeLocalUserNameFailed
    /// Session error, failed to change one participant's name.
    case ChangeSingleParticipantNameFailed
    /// Session error, failed to send unmute request to all participants.
    case RequestToUnmuteEveryoneFailed
    /// Session error, failed to mute all participants.
    case MuteEveryoneFailed
    /// Session error, failed to send unmute request to single participant.
    case RequestToUnmuteSingleParticipantFailed
    /// Session error, failed to mute single participant.
    case MuteSingleParticipantFailed
    /// Session error, failed to revoke manager.
    case RevokeManagerFailed
    /// Session error, failed to grant manager.
    case GrantManagerFailed
    /// Session error, failed to change host.
    case ChangeHostFailed
    /// Session error, failed to remove participant.
    case RemoveParticipantFailed
    /// Session error, failed to end session.
    case EndSessionFailed
    
    /// Provides a more descriptive error information.
    public var description: (String) {
        switch self {
        case .EmptyKeyOrSecret:
            return "Authentication error, no key or secret found."
        case .InvalidKeyOrSecret:
            return "Authentication error, wrong key or secret."
        case .EmptySessionName:
            return "Join session error, no tpc (topic) name."
        case .EmptySessionToken:
            return "Join session error, no session token."
        case .TokenEmptySessionName:
            return "Join Session error, no session name within token."
        case .EmptyUsername:
            return "Join session error, no session user name."
        case .InvalidSessionName:
            return "Join session error, invalid session name."
        case .WrongPassword:
            return "Join session error, invalid session password."
        case .InvalidSessionToken:
            return "Join session error, invalid session token."
        case .MissingPassword:
            return "Join session error, missing session password."
        case .SessionNameTooLong:
            return "Join Session error, session name too long."
        case .TokenMismatchedSessionName:
            return "Join session token error, mismatched session name."
        case .TokenUserIdentityTooLong:
            return "Join session token error, user identity too long."
        case .InvalidParam:
            return "Join session error, invalid parameter."
        case .JoinFailed:
            return "Join session error, failed to join session."
        case .NoMicrophonePermission:
            return "Session error, no microphone permission."
        case .NoCameraPermission:
            return "Session error, no camera permission."
        case .LeaveSessionFailed:
            return "Session error, failed to leave session."
        case .MuteMicFailed:
            return "Session error, failed to mute mic."
        case .UnmuteMicFailed:
            return "Session error, failed to unmute mic."
        case .StartCameraFailed:
            return "Session error, failed to start video."
        case .StopCameraFailed:
            return "Session error, failed to stop video."
        case .SendGroupMessageFailed:
            return "Session error, failed to send message."
        case .SendPrivateMessageFailed:
            return "Session error, failed to send private message."
        case .EnableGroupAndPrivateChatFailed:
            return "Session error, failed to enable group and private chat."
        case .DisableGroupAndPrivateChatFailed:
            return "Session error, failed to disable group and private chat."
        case .ChangeVirtualBackgroundFailed:
            return "Session error, failed to change virtual background."
        case .ChangeLocalUserNameFailed:
            return "Session error, failed to change local user's name."
        case .ChangeSingleParticipantNameFailed:
            return "Session error, failed to change one participant's name."
        case .RequestToUnmuteEveryoneFailed:
            return "Session error, failed to send unmute request to all participants."
        case .MuteEveryoneFailed:
            return "Session error, failed to mute all participants."
        case .RequestToUnmuteSingleParticipantFailed:
            return "Session error, failed to send unmute request to single participant."
        case .MuteSingleParticipantFailed:
            return "Session error, failed to mute single participant."
        case .RevokeManagerFailed:
            return "Session error, failed to revoke manager."
        case .GrantManagerFailed:
            return "Session error, failed to grant manager."
        case .ChangeHostFailed:
            return "Session error, failed to change host."
        case .RemoveParticipantFailed:
            return "Session error, failed to remove participant."
        case .EndSessionFailed:
            return "Session error, failed to end session."
        }
    }
    
}

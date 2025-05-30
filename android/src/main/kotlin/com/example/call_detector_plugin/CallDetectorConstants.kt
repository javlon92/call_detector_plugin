package com.example.call_detector_plugin

import android.media.AudioManager

object ChannelConstants {
    const val METHOD_CHANNEL = "call_detector_method_channel"
    const val EVENT_CHANNEL = "call_detector_event_channel"
}

object MethodConstants {
    const val GET_CURRENT_STATUS = "get_current_status"
}

// Documentation link:  https://developer.android.com/reference/android/media/AudioManager

enum class AudioFocusState(val label: String) {
    GAIN("AUDIOFOCUS_GAIN"),                                           // Полный фокус получен
    GAIN_TRANSIENT("AUDIOFOCUS_GAIN_TRANSIENT"),                       // Временный фокус
    GAIN_TRANSIENT_MAY_DUCK("AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK"),     // Временный с возможностью утихания
    GAIN_TRANSIENT_EXCLUSIVE("AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE"),   // Временный эксклюзивный фокус
    LOSS("AUDIOFOCUS_LOSS"),                                           // Потеря фокуса
    LOSS_TRANSIENT("AUDIOFOCUS_LOSS_TRANSIENT"),                       // Временная потеря
    LOSS_TRANSIENT_CAN_DUCK("AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK"),     // Временная потеря с возможностью утихания
    UNKNOWN("UNKNOWN");                                                // Неизвестное значение

    override fun toString(): String = label

    val isGain: Boolean
        get() = this == GAIN ||
                this == GAIN_TRANSIENT ||
                this == GAIN_TRANSIENT_MAY_DUCK ||
                this == GAIN_TRANSIENT_EXCLUSIVE

    val isLossTransient: Boolean
        get() = this == LOSS_TRANSIENT

    val isLoss: Boolean
        get() = this == LOSS

    val isNotLoss: Boolean
        get() = !isLoss

    val isUnknown: Boolean
        get() = this == UNKNOWN

    val isNotUnknown: Boolean
        get() = !isUnknown

    companion object {
        fun from(focusChange: Int): AudioFocusState = when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> GAIN
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT -> GAIN_TRANSIENT
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK -> GAIN_TRANSIENT_MAY_DUCK
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE -> GAIN_TRANSIENT_EXCLUSIVE
            AudioManager.AUDIOFOCUS_LOSS -> LOSS
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> LOSS_TRANSIENT
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> LOSS_TRANSIENT_CAN_DUCK
            else -> UNKNOWN
        }
    }

    fun <T> maybeWhen(
        gain: (() -> T)? = null,
        gainTransient: (() -> T)? = null,
        gainTransientMayDuck: (() -> T)? = null,
        gainTransientExclusive: (() -> T)? = null,
        loss: (() -> T)? = null,
        lossTransient: (() -> T)? = null,
        lossTransientCanDuck: (() -> T)? = null,
        unknown: (() -> T)? = null,
        orElse: () -> T
    ): T {
        return when (this) {
            AudioFocusState.GAIN -> gain?.invoke() ?: orElse()
            AudioFocusState.GAIN_TRANSIENT -> gainTransient?.invoke() ?: orElse()
            AudioFocusState.GAIN_TRANSIENT_MAY_DUCK -> gainTransientMayDuck?.invoke() ?: orElse()
            AudioFocusState.GAIN_TRANSIENT_EXCLUSIVE -> gainTransientExclusive?.invoke() ?: orElse()
            AudioFocusState.LOSS -> loss?.invoke() ?: orElse()
            AudioFocusState.LOSS_TRANSIENT -> lossTransient?.invoke() ?: orElse()
            AudioFocusState.LOSS_TRANSIENT_CAN_DUCK -> lossTransientCanDuck?.invoke() ?: orElse()
            AudioFocusState.UNKNOWN -> unknown?.invoke() ?: orElse()
        }
    }

}

// Documentation link:  https://developer.android.com/reference/android/media/AudioManager

enum class CallAudioMode(val label: String) {
    CURRENT("MODE_CURRENT"),                                 // Текущий режим
    NORMAL("MODE_NORMAL"),                                   // Обычный режим (не в звонке)
    RINGTONE("MODE_RINGTONE"),                               // Входящий вызов
    IN_CALL("MODE_IN_CALL"),                                 // Телефонный звонок (GSM/CDMA)
    IN_COMMUNICATION("MODE_IN_COMMUNICATION"),               // VoIP или видео-звонок
    CALL_SCREENING("MODE_CALL_SCREENING"),                   // Режим фильтрации звонков (Android 11+, API 30+)
    CALL_REDIRECT("MODE_CALL_REDIRECT"),                     // Режим перенаправления звонков (Android 13+, API 33+)
    COMMUNICATION_REDIRECT("MODE_COMMUNICATION_REDIRECT"),   // Режим перенаправления коммуникаций (Android 13+, API 33+)
    UNKNOWN("UNKNOWN");                                      // Неизвестное значение

    override fun toString(): String = label

    val isInCall: Boolean
        get() = this == IN_CALL || this == IN_COMMUNICATION

    val isRinging: Boolean
        get() = this == RINGTONE

    val isNormal: Boolean
        get() = this == NORMAL

    val isRingingOrNormal: Boolean
        get() = isNormal || isRinging

    companion object {
        fun from(mode: Int): CallAudioMode = when (mode) {
            AudioManager.MODE_CURRENT -> CURRENT
            AudioManager.MODE_NORMAL -> NORMAL
            AudioManager.MODE_RINGTONE -> RINGTONE
            AudioManager.MODE_IN_CALL -> IN_CALL
            AudioManager.MODE_IN_COMMUNICATION -> IN_COMMUNICATION
            AudioManager.MODE_CALL_SCREENING -> CALL_SCREENING
            AudioManager.MODE_CALL_REDIRECT -> CALL_REDIRECT
            AudioManager.MODE_COMMUNICATION_REDIRECT -> COMMUNICATION_REDIRECT
            else -> UNKNOWN
        }
    }

    fun <T> maybeWhen(
        current: (() -> T)? = null,
        normal: (() -> T)? = null,
        ringtone: (() -> T)? = null,
        inCall: (() -> T)? = null,
        inCommunication: (() -> T)? = null,
        callScreening: (() -> T)? = null,
        callRedirect: (() -> T)? = null,
        communicationRedirect: (() -> T)? = null,
        unknown: (() -> T)? = null,
        orElse: () -> T
    ): T {
        return when (this) {
            CURRENT -> current?.invoke() ?: orElse()
            NORMAL -> normal?.invoke() ?: orElse()
            RINGTONE -> ringtone?.invoke() ?: orElse()
            IN_CALL -> inCall?.invoke() ?: orElse()
            IN_COMMUNICATION -> inCommunication?.invoke() ?: orElse()
            CALL_SCREENING -> callScreening?.invoke() ?: orElse()
            CALL_REDIRECT -> callRedirect?.invoke() ?: orElse()
            COMMUNICATION_REDIRECT -> communicationRedirect?.invoke() ?: orElse()
            UNKNOWN -> unknown?.invoke() ?: orElse()
        }
    }
}





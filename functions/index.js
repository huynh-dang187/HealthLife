// Re-export tất cả functions từ các module con
export { generateDailyTip, testGenerateTip } from './src/features/daily_tips.js';
export { triggerSosAlert } from './src/features/sos_iot.js';
export { validateDailyStepRecord } from './src/features/daily_step.js';
export { chatbotMessage, chatbotGenerateTitle } from './src/features/chatbot.js';
export { checkPhoneRegistered } from './src/features/auth_check.js';
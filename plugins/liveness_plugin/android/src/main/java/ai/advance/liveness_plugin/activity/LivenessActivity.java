package ai.advance.liveness_plugin.activity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import android.util.SparseArray;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import ai.advance.common.IMediaPlayer;
import ai.advance.common.utils.SystemUtil;
import ai.advance.core.PermissionActivity;
import ai.advance.liveness.lib.Detector;
import ai.advance.liveness.lib.GuardianLivenessDetectionSDK;
import ai.advance.liveness.lib.LivenessResult;
import ai.advance.liveness.lib.LivenessView;
import ai.advance.liveness.lib.http.entity.ResultEntity;
import ai.advance.liveness.lib.impl.LivenessCallback;
import ai.advance.liveness.lib.impl.LivenessGetFaceDataCallback;
import ai.advance.liveness_plugin.R;

/**
 * createTime:6/7/21
 *
 * @author fan.zhang@advance.ai
 */
public class LivenessActivity extends PermissionActivity implements LivenessCallback {
    /**
     * the array of tip imageView animationDrawable
     * 动作提示 imageView 的图像集合
     */
    private SparseArray<AnimationDrawable> mDrawableCache;
    /**
     * the circle mask view above livenessView
     * 蒙版控件
     */
    protected ImageView mMaskImageView;
    /**
     * liveness function view
     * 活体检测功能控件
     */
    private LivenessView mLivenessView;
    /**
     * bottom anim tip imageView
     * 底部提示动画控件
     */
    private ImageView mTipImageView;
    /**
     * bottom tip textView
     * 底部提示文本控件
     */
    private TextView mTipTextView;
    /**
     * the countdown timer view
     * 倒计时控件
     */
    private TextView mTimerView;
    /**
     * open/close sounds checkbox
     * 打开/关闭声音的单选框
     */
    private CheckBox mVoiceCheckBox;
    /**
     * the loading dialog after all action success
     * 全部动作成功后的加载框
     */
    private View mProgressLayout;
    /**
     * auth loading dialog
     * 授权过程的加载框
     */
    ProgressDialog mInitProgressDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_liveness);
        SystemUtil.changeActivityBrightness(this, 255);
        findViews();
        initData();
        if (GuardianLivenessDetectionSDK.isSDKHandleCameraPermission() && !allPermissionsGranted()) {
            requestPermissions();
        }
    }


    /**
     * init fields
     * 初始化变量
     */
    private void initData() {
        mDrawableCache = new SparseArray<>();
        mLivenessView.setLivenssCallback(this);
    }

    /**
     * init views
     * 初始化控件
     */
    protected void findViews() {
        mMaskImageView = findViewById(R.id.mask_view);
        mLivenessView = findViewById(R.id.liveness_view);
        mTipImageView = findViewById(R.id.tip_image_view);
        mTipTextView = findViewById(R.id.tip_text_view);
        mTimerView = findViewById(R.id.timer_text_view_camera_activity);
        mProgressLayout = findViewById(R.id.progress_layout);
        mVoiceCheckBox = findViewById(R.id.voice_check_box);
        View mBackView = findViewById(R.id.back_view_camera_activity);
        mBackView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        mVoiceCheckBox.setChecked(IMediaPlayer.isPlayEnable());
        mVoiceCheckBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mLivenessView.setSoundPlayEnable(isChecked);
                if (isChecked) {
                    playSound();
                }
            }
        });
    }

    /**
     * play sound
     * 播放语音
     */
    private void playSound() {
        if (mVoiceCheckBox.getVisibility() != View.VISIBLE) {
            mVoiceCheckBox.setVisibility(View.VISIBLE);
        }
        int resID = -1;
        Detector.DetectionType detectionType = mLivenessView.getCurrentDetectionType();
        if (detectionType != null) {
            switch (detectionType) {
                case POS_YAW:
                    resID = R.raw.action_turn_head;
                    break;
                case MOUTH:
                    resID = R.raw.action_open_mouth;
                    break;
                case BLINK:
                    resID = R.raw.action_blink;
                    break;
            }
        }
        mLivenessView.playSound(resID, true, 1500);
    }

    /**
     * update tip text
     * 更新提示语文案
     *
     * @param strResId resId 资源id
     */
    private void changeTipTextView(int strResId) {
        mTipTextView.setText(strResId);
    }

    /**
     * update tip textView text
     * 更新提示文本的文案
     *
     * @param warnCode the status of current frame 当前的状态
     */
    private void updateTipUIView(Detector.WarnCode warnCode) {
        if (mLivenessView.isVertical()) {//phone not vertical
            if (warnCode != null) {
                switch (warnCode) {
                    case FACEMISSING:
                        changeTipTextView(R.string.liveness_no_people_face);
                        break;
                    case FACESMALL:
                        changeTipTextView(R.string.liveness_tip_move_closer);
                        break;
                    case FACELARGE:
                        changeTipTextView(R.string.liveness_tip_move_furthre);
                        break;
                    case FACENOTCENTER:
                        changeTipTextView(R.string.liveness_move_face_center);
                        break;
                    case FACENOTFRONTAL:
                        changeTipTextView(R.string.liveness_frontal);
                        break;
                    case FACENOTSTILL:
                    case FACECAPTURE:
                        changeTipTextView(R.string.liveness_still);
                        break;
                    case WARN_MOUTH_OCCLUSION:
                        changeTipTextView(R.string.liveness_face_occ);
                        break;
                    case FACEINACTION:
                        showActionTipUIView();
                        break;
                }
            }
        } else {
            changeTipTextView(R.string.liveness_hold_phone_vertical);
        }
    }

    /**
     * show current action tips
     * 显示当前动作的动画提示
     */
    private void showActionTipUIView() {
        Detector.DetectionType currentDetectionType = mLivenessView.getCurrentDetectionType();
        if (currentDetectionType != null) {
            int detectionNameId = 0;
            switch (currentDetectionType) {
                case POS_YAW:
                    detectionNameId = R.string.liveness_pos_raw;
                    break;
                case MOUTH:
                    detectionNameId = R.string.liveness_mouse;
                    break;
                case BLINK:
                    detectionNameId = R.string.liveness_blink;
                    break;
            }
            changeTipTextView(detectionNameId);
            AnimationDrawable anim = getDrawRes(currentDetectionType);
            mTipImageView.setImageDrawable(anim);
            anim.start();
        }
    }

    /**
     * called by when detection auth start
     * 活体检测授权开始时会执行该方法
     */
    @Override
    public void onDetectorInitStart() {
        if (mInitProgressDialog != null) {
            mInitProgressDialog.dismiss();
        }
        mInitProgressDialog = new ProgressDialog(this);
        mInitProgressDialog.setMessage(getString(R.string.liveness_auth_check));
        mInitProgressDialog.setCanceledOnTouchOutside(false);
        mInitProgressDialog.show();
    }

    /**
     * called by when detection auth complete
     * 活体检测授权完成后会执行该方法
     *
     * @param isValid   whether the auth is success 活体检测是否成功
     * @param errorCode the error code 错误码
     * @param message   the error message 错误信息
     */
    @Override
    public void onDetectorInitComplete(final boolean isValid, final String errorCode,
                                       final String message) {
        if (mInitProgressDialog != null) {
            mInitProgressDialog.dismiss();
        }
        if (isValid) {
            updateTipUIView(null);
        } else {
            final String errorMessage;
            if (LivenessView.NO_RESPONSE.equals(errorCode)) {
                errorMessage = getString(R.string.liveness_failed_reason_auth_failed);
            } else {
                errorMessage = message;
            }
            new AlertDialog.Builder(this).setMessage(errorMessage).setPositiveButton(R.string.liveness_perform, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    LivenessResult.setErrorMsg(errorMessage);
                    dialog.dismiss();
                    setResult(Activity.RESULT_OK);
                    finish();
                }
            }).create().show();
        }
    }

    /**
     * Get the prompt picture/animation according to the action type
     * 根据动作类型获取动画资源
     *
     * @param detectionType Action type 动作类型
     * @return Prompt picture/animation
     */
    public AnimationDrawable getDrawRes(Detector.DetectionType detectionType) {
        int resID = -1;
        if (detectionType != null) {
            switch (detectionType) {
                case POS_YAW:
                    resID = R.drawable.anim_frame_turn_head;
                    break;
                case MOUTH:
                    resID = R.drawable.anim_frame_open_mouse;
                    break;
                case BLINK:
                    resID = R.drawable.anim_frame_blink;
                    break;
            }
        }
        AnimationDrawable cachedDrawAble = mDrawableCache.get(resID);
        if (cachedDrawAble == null) {
            AnimationDrawable drawable = (AnimationDrawable) getResources().getDrawable(resID);
            mDrawableCache.put(resID, (drawable));
            return drawable;
        } else {
            return cachedDrawAble;
        }
    }

    /**
     * called by first action start or after an action finish
     * 当准备阶段完成时，以及每个动作完成后，会执行该方法
     */
    @Override
    public void onDetectionActionChanged() {
        playSound();
        showActionTipUIView();
        mTimerView.setBackgroundResource(R.drawable.liveness_shape_right_timer);
    }

    /**
     * called by local liveness detection success
     * 活体检测成功时会执行该方法
     */
    @Override
    public void onDetectionSuccess() {
        mLivenessView.getLivenessData(new LivenessGetFaceDataCallback() {

            @Override
            public void onGetFaceDataStart() {
                mProgressLayout.setVisibility(View.VISIBLE);
                mTimerView.setVisibility(View.INVISIBLE);
                mLivenessView.setVisibility(View.INVISIBLE);
                mVoiceCheckBox.setVisibility(View.INVISIBLE);
                mTipImageView.setVisibility(View.INVISIBLE);
                mTipTextView.setVisibility(View.INVISIBLE);
                mMaskImageView.setVisibility(View.INVISIBLE);
            }

            @Override
            public void onGetFaceDataSuccess(ResultEntity entity, String livenessId) {
                // liveness detection success
                setResultData();
            }

            @Override
            public void onGetFaceDataFailed(ResultEntity entity) {
                if (!entity.success && LivenessView.NO_RESPONSE.equals(entity.code)) {
                    LivenessResult.setErrorMsg(getString(R.string.liveness_failed_reason_bad_network));
                }
                setResultData();
            }
        });
    }

    private void setResultData() {
        setResult(Activity.RESULT_OK);
        finish();
    }

    /**
     * called by current frame is warn or become normal,is necessary to update tip UI
     * 当前帧的状态发生异常或者从异常状态变为正常的时候，需要更新 UI 上的提示语
     *
     * @param warnCode status of current frame 本帧的状态
     */
    @Override
    public void onDetectionFrameStateChanged(Detector.WarnCode warnCode) {
        updateTipUIView(warnCode);
    }

    /**
     * called by Remaining time changed of current action,is necessary to update countdown timer view
     * 当前动作剩余时间变化,需要更新倒计时控件上的时间
     *
     * @param remainingTimeMills remaining time of current action 毫秒单位的剩余时间
     */
    @SuppressLint("SetTextI18n")
    @Override
    public void onActionRemainingTimeChanged(long remainingTimeMills) {
        final int mills = (int) (remainingTimeMills / 1000);
        mTimerView.setText(mills + "s");
    }

    /**
     * called by detection failed
     * 活体检测失败时的回调
     *
     * @param failedType    Type of failures 失败的类型
     * @param detectionType Type of action 失败的原因
     */
    @Override
    public void onDetectionFailed(Detector.DetectionFailedType failedType, Detector.DetectionType detectionType) {
        switch (failedType) {
            case WEAKLIGHT:
                changeTipTextView(R.string.liveness_weak_light);
                break;
            case STRONGLIGHT:
                changeTipTextView(R.string.liveness_too_light);
                break;
            default:
                String errorMsg = null;
                switch (failedType) {
                    case FACEMISSING:
                        switch (detectionType) {
                            case MOUTH:
                            case BLINK:
                                errorMsg = getString(R.string.liveness_failed_reason_facemissing_blink_mouth);
                                break;
                            case POS_YAW:
                                errorMsg = getString(R.string.liveness_failed_reason_facemissing_pos_yaw);
                                break;
                        }
                        break;
                    case TIMEOUT:
                        errorMsg = getString(R.string.liveness_failed_reason_timeout);
                        break;
                    case MULTIPLEFACE:
                        errorMsg = getString(R.string.liveness_failed_reason_multipleface);
                        break;
                    case MUCHMOTION:
                        errorMsg = getString(R.string.liveness_failed_reason_muchaction);
                        break;
                }
                LivenessResult.setErrorMsg(errorMsg);
                setResultData();
                break;
        }
    }

    @Override
    protected void onResume() {
        uiReset();
        if (allPermissionsGranted()) {
            mLivenessView.onResume();
        }
        super.onResume();
    }

    @Override
    protected void onPause() {
        if (mInitProgressDialog != null) {
            mInitProgressDialog.dismiss();
        }
        mLivenessView.onPause();
        super.onPause();
    }

    private void uiReset() {
        mLivenessView.setVisibility(View.VISIBLE);
        mTipTextView.setVisibility(View.VISIBLE);
        mTipImageView.setVisibility(View.VISIBLE);
        mMaskImageView.setVisibility(View.VISIBLE);
        mTimerView.setText("");
        mTimerView.setBackgroundResource(0);
        mTimerView.setVisibility(View.VISIBLE);
        mVoiceCheckBox.setVisibility(View.INVISIBLE);
        mTipImageView.setImageDrawable(null);

        mProgressLayout.setVisibility(View.INVISIBLE);
    }

    @Override
    protected void onDestroy() {
        mLivenessView.onDestroy();
        super.onDestroy();
    }

    @Override
    protected String[] getRequiredPermissions() {
        return new String[]{Manifest.permission.CAMERA};
    }

    @Override
    protected void onPermissionGranted() {

    }

    @Override
    protected void onPermissionRefused() {
        new AlertDialog.Builder(this).setMessage(getString(R.string.liveness_no_camera_permission)).setPositiveButton(getString(R.string.liveness_perform), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                finish();
            }
        }).create().show();
    }
}

package ai.advance.liveness_plugin;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import ai.advance.liveness.lib.Detector;
import ai.advance.liveness.lib.GuardianLivenessDetectionSDK;
import ai.advance.liveness.lib.LivenessResult;
import ai.advance.liveness.lib.Market;
import ai.advance.liveness_plugin.activity.LivenessActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class LivenessPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware
{
	private static final String INIT_SDK                 = "initSDK";
	private static final String INIT_SDK_OF_LICENSE      = "initSDKOfLicense";
	private static final String SET_LICENSE_AND_CHECK    = "setLicenseAndCheck";
	private static final String START_LIVENESS_DETECTION = "startLivenessDetection";
	private static final String SET_ACTION_SEQUENCE      = "setActionSequence";
	private static final String BIND_USER                = "bindUser";
	private static final String SET_DETECTION_OCCLUSION  = "setDetectOcclusion";
	private static final String SET_RESULT_PICTURE_SIZE  = "setResultPictureSize";
	
	private static final String                GET_SDK_VERSION             = "getSDKVersion";
	private static final String                GET_LATEST_DETECTION_RESULT = "getLatestDetectionResult";
	private static final int                   REQUEST_CODE_LIVENESS       = 1002;
	private              Activity              mActivity;
	private              Application           application;
	private              MethodChannel         mMethodChannel;
	private              ActivityPluginBinding binding;
	//	private              EventChannel.EventSink mEventSink;
	
	private PluginRegistry.ActivityResultListener mActivityResultListener;
	
	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding)
	{
		mMethodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "liveness_plugin");
		mMethodChannel.setMethodCallHandler(this);
	}
	
	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding)
	{
		mMethodChannel.setMethodCallHandler(null);
	}
	
	
	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull Result result)
	{
		switch (call.method)
		{
			case INIT_SDK:
				initSDK(call, result);
				break;
			case INIT_SDK_OF_LICENSE:
				initSDKOfLicense(call, result);
				break;
			case SET_LICENSE_AND_CHECK:
				result.success(GuardianLivenessDetectionSDK.setLicenseAndCheck(call.argument("license").toString()));
				break;
			case START_LIVENESS_DETECTION:
				startLivenessDetection();
				break;
			case SET_ACTION_SEQUENCE:
				setActionSequence(call, result);
				break;
			case BIND_USER:
				GuardianLivenessDetectionSDK.bindUser(Objects.requireNonNull(call.argument("userId")).toString());
				break;
			case GET_SDK_VERSION:
				result.success(GuardianLivenessDetectionSDK.getSDKVersion());
				break;
			case GET_LATEST_DETECTION_RESULT:
				result.success(getDetectionResultMap());
				break;
			case SET_DETECTION_OCCLUSION:
				GuardianLivenessDetectionSDK.isDetectOcclusion(Boolean.TRUE.equals(call.<Boolean>argument("detectOcclusion")));
				break;
			case SET_RESULT_PICTURE_SIZE:
				GuardianLivenessDetectionSDK.setResultPictureSize(call.<Integer>argument("resultPictureSize"));
				break;
			default:
				result.notImplemented();
				break;
		}
	}
	
	private void initSDK(MethodCall methodCall, Result result)
	{
		String marketStr = methodCall.argument("market");
		Market market    = null;
		try
		{
			market = Market.valueOf(marketStr);
		}
		catch (Exception e)
		{
			result.error("ERROR_MARKET", "Market is error,please check", null);
		}
		if (market != null)
		{
			String  accessKey       = methodCall.argument("accessKey");
			String  secretKey       = methodCall.argument("secretKey");
			Boolean isGlobalService = methodCall.argument("isGlobalService");
			if (isGlobalService == null)
			{
				isGlobalService = false;
			}
			assert secretKey != null;
			assert accessKey != null;
			GuardianLivenessDetectionSDK.init(application, accessKey, secretKey, market, isGlobalService);
			GuardianLivenessDetectionSDK.letSDKHandleCameraPermission();
			mMethodChannel.invokeMethod("init", null);
		}
		
	}
	
	private void initSDKOfLicense(MethodCall methodCall, Result result)
	{
		String marketStr = methodCall.argument("market");
		Market market    = null;
		try
		{
			market = Market.valueOf(marketStr);
		}
		catch (Exception e)
		{
			result.error("ERROR_MARKET", "Market is error,please check", null);
		}
		if (market != null)
		{
			Boolean isGlobalService = methodCall.argument("isGlobalService");
			if (isGlobalService == null)
			{
				isGlobalService = false;
			}
			GuardianLivenessDetectionSDK.init(application, market, isGlobalService);
			GuardianLivenessDetectionSDK.letSDKHandleCameraPermission();
			
			mMethodChannel.invokeMethod("initSDKOfLicense", null);
		}
		
	}
	
	private void startLivenessDetection()
	{
		Intent intent = new Intent(mActivity, LivenessActivity.class);
		mActivity.startActivityForResult(intent, REQUEST_CODE_LIVENESS);
		addActivityResultListener();
	}
	
	private void setActionSequence(MethodCall methodCall, Result result)
	{
		boolean shuffle = Boolean.TRUE.equals(methodCall.argument("shuffle"));
		
		ArrayList<String>        actionSequence = methodCall.argument("actionSequence");
		Detector.DetectionType[] detectionTypes = new Detector.DetectionType[actionSequence.size()];
		for (int i = 0; i < actionSequence.size(); i++)
		{
			detectionTypes[i] = Detector.DetectionType.valueOf(actionSequence.get(i));
		}
		GuardianLivenessDetectionSDK.setActionSequence(shuffle, detectionTypes);
	}
	
	@Override
	public void onAttachedToActivity(@NonNull ActivityPluginBinding binding)
	{
		mActivity = binding.getActivity();
		application = mActivity.getApplication();
		this.binding = binding;
	}
	
	private synchronized void addActivityResultListener()
	{
		if (binding != null)
		{
			if (mActivityResultListener == null)
			{
				mActivityResultListener = (requestCode, resultCode, data) -> {
					if (requestCode == REQUEST_CODE_LIVENESS)
					{
						Map resultMap = getDetectionResultMap();
						if (LivenessResult.isSuccess())
						{
							mMethodChannel.invokeMethod("onDetectionSuccess", resultMap);
						}
						else
						{
							mMethodChannel.invokeMethod("onDetectionFailure", resultMap);
						}
						return true;
					}
					return false;
				};
				binding.addActivityResultListener(mActivityResultListener);
			}
			
		}
	}
	
	private Map getDetectionResultMap()
	{
		Map<String, Object> resultMap = new HashMap<String, Object>();
		resultMap.put("isSuccess", LivenessResult.isSuccess());
		resultMap.put("livenessId", LivenessResult.getLivenessId());
		resultMap.put("base64Image", LivenessResult.getLivenessBase64Str());
		if (LivenessResult.isSuccess())
		{
			resultMap.put("code", "SUCCESS");
		}
		else
		{
			resultMap.put("code", LivenessResult.getErrorCode());
		}
		resultMap.put("message", LivenessResult.getErrorMsg());
		resultMap.put("transactionId", LivenessResult.getTransactionId());
		resultMap.put("isPay", LivenessResult.isPay());
		return resultMap;
	}
	
	@Override
	public void onDetachedFromActivityForConfigChanges()
	{
		onDetachedFromActivity();
	}
	
	@Override
	public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding)
	{
		onAttachedToActivity(binding);
	}
	
	@Override
	public void onDetachedFromActivity()
	{
		this.mActivity = null;
		this.application = null;
	}
	
	//	@Override
	//	public void onListen(Object arguments, EventChannel.EventSink events)
	//	{
	//		mEventSink = events;
	//	}
	//
	//	@Override
	//	public void onCancel(Object arguments)
	//	{
	//		mEventSink = null;
	//	}
}
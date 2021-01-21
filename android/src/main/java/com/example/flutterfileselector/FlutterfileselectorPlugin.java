package com.example.flutterfileselector;
import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterfileselectorPlugin */
public class FlutterfileselectorPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static PluginRegistry.Registrar registrarFlutter;
  private static Context context;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutterfileselector");
    channel.setMethodCallHandler(this);
  }

    //此静态功能是可选的，相当于onAttachedToEngine。它支持老人

    //pre-Flutter-1.12 Android项目。我们鼓励你继续支持

  //当应用程序迁移到使用新的Android api时，通过此功能进行插件注册 onAttachedToEngine
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    // 先保存Registrar对象
    FlutterfileselectorPlugin.registrarFlutter = registrar;
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutterfileselector");
    channel.setMethodCallHandler(new FlutterfileselectorPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getFile")) {

      Log.d("安卓原生端接收参数：",call.arguments.toString());

      // 接收的参数
      List<String> type = call.argument("type");

      // 返回的参数
      List<Map> listMap = new ArrayList<>();

      try{
        // 得到对应类型文件  type.toArray(new String[type.size()])转换类型
        List<String> list   = FileUtilFlutter.getTypeOfFile(context, type.toArray(new String[type.size()]));
        File f ;
        for(String item : list){
          f = new File(item);
          // 拼接参数
          Map<String,Object> m = new HashMap();
          m.put("fileName",f.getName());
          m.put("filePath",f.getAbsolutePath());
          m.put("fileSize",f.length());
          m.put("fileDate",f.lastModified());
          listMap.add(m);
        }
      }finally {
        // 返回给flutter
        result.success(listMap);
      }

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

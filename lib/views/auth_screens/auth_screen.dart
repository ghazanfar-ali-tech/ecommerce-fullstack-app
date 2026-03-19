import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/views/auth_screens/forgot_password_screen.dart';
import 'package:ecommerceapp/views/bottom_navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:ecommerceapp/resources/components/custom_field.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                     gradient: AppColors.heroGradient, 
                    ),
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: Lottie.asset(
                          'assets/Animation - 1743764351883.json',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 295,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Container(
                              height: 47,
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: AppColors.primary, 
                                  width: 0.5,
                                ),
                                color: AppColors.surfaceVariant(context),
                              ),
                              child: Consumer<AuthViewModel>(
                                builder: (context, model, child) {
                                  return Stack(
                                    children: [
                                      AnimatedAlign(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        alignment: model.isLoginSelected
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Container(
                                          width: 150,
                                          height: 50,
                                          decoration: BoxDecoration(
                                             gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 140,
                                              child: TextButton(
                                                onPressed: () =>
                                                    model.selectLogin(),
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    fontSize: 15.3,
                                                    fontWeight: FontWeight.bold,
                                                    color: model.isLoginSelected
                                                       ? Colors.white          
                                                        : AppColors.primaryText(context),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 140,
                                              child: TextButton(
                                                onPressed: () =>
                                                    model.selectSignIn(),
                                                child: Text(
                                                  "Sign Up",
                                                  style: TextStyle(
                                                    fontSize: 15.3,
                                                    fontWeight: FontWeight.bold,
                                                    color: model.isLoginSelected
                                                       ? AppColors.primaryText(context) // idle
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 20),

                            Consumer<AuthViewModel>(
                              builder: (context, model, child) {
                                return Form(
                                  key: _formkey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                 
                                      AnimatedSize(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 400),
                                          transitionBuilder: (child, animation) {
                                            final offsetAnim = Tween<Offset>(
                                              begin: Offset(0, -0.3),
                                              end: Offset(0, 0),
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOut,
                                            ));
                                            return SlideTransition(
                                              position: offsetAnim,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: model.isLoginSelected
                                              ? SizedBox.shrink(
                                                  key: ValueKey('empty'),
                                                )
                                              : Column(
                                                  children: [
                                                    customField(
                                                      context: context,
                                                      controller: context.read<AuthViewModel>().usernameController,
                                                      hintName: "Name",
                                                      icon: Icons.person,
                                                      labelText: "Name",
                                                      validator: (value){
                                                        if(value!.isEmpty){
                                                          return "Enter user name";
                                                        }
                                                        return null;
                                                      }
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                        ),
                                      ),
                                  
                                   
                                      AnimatedSlide(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        offset: model.isLoginSelected
                                            ? Offset(0, 0)
                                            : Offset(0, 0),
                                        child: Column(
                                          children: [
                                            customField(
                                              context: context,
                                              controller: context.read<AuthViewModel>().emailController,
                                              hintName: "Email",
                                              icon: Icons.email_outlined,
                                              labelText: "Email",
                                              validator: (value){
                                                        if(value!.isEmpty){
                                                          return "Enter email";
                                                        }
                                                        return null;
                                                      }
                                            ),
                                            SizedBox(height: 10),
                                             customField(
                                              context: context,
                                          controller: context.read<AuthViewModel>().passwordController,
                                          hintName: "Password",
                                          labelText: "Password",
                                          icon: Icons.lock_outline_rounded,
                                          validator: (value){
                                                        if(value!.isEmpty){
                                                          return "Enter Password";
                                                        }
                                                        return null;
                                                      }
                                        )
                                          ],
                                        ),
                                      ),
                                  
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 5),

                            Consumer<AuthViewModel>(
                              builder: (context, model, child) {
                                return GestureDetector(
                                  onTap: () {
                                    if (model.isLoginSelected) {
                                      print("Login clicked");
                                      model.login(context,context.read<NotificationViewModel>());
                                    } else {
                                      print("Sign Up clicked");
                                      model.signUp(context,context.read<NotificationViewModel>());
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 600),
                                    curve: Curves.easeInOut,
                                    margin: EdgeInsets.only(top: 20),
                                    width: 300,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      boxShadow: [BoxShadow()],
                                      gradient:AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 600),
                                        transitionBuilder: (child, animation) {
                                          final offsetAnim = Tween<Offset>(
                                            begin: Offset(0, -0.5),
                                            end: Offset(0, 0),
                                          ).animate(animation);
                                          return SlideTransition(
                                            position: offsetAnim,
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          model.isLoginSelected
                                              ? "Login"
                                              : "Sign Up",
                                          key: ValueKey(model.isLoginSelected),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                   Navigator.push(context, MaterialPageRoute(builder: (_)=>ForgotPasswordScreen()));
                                },
                                child: Text(
                                  'Forgot password',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 85, 59, 59),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 1.2,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'Or',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1.2,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 20,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                   final user = await context.read<AuthViewModel>().loginWithGoogle(context);
                                   if (user != null) {
                                  
                                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BottomNavigation()));
                                   } else {
                                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen()));
                                   }
                                 },
                                  icon: Image(
                                    height: 35,
                                    width: 35,
                                    image: AssetImage("assets/google.png"),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Image(
                                    height: 35,
                                    width: 35,
                                    image: AssetImage("assets/facebook.png"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
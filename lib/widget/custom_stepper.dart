import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int) onStepTapped;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: List.generate(steps.length, (index) {
        return Expanded(
          child: InkWell(
            onTap: () => onStepTapped(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cercle
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: screenHeight * 0.035,
                      height: screenHeight * 0.035,
                      decoration: BoxDecoration(
                        color: index <= currentStep
                            ? Colors.amber
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: index < currentStep
                            ? Icon(Icons.check, size: 18, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index <= currentStep
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                      ),
                    ),

                    // Ligne
                    if (index != steps.length - 1)
                    Center(
                      child:  Container(
                          height: 3,
                          color: index < currentStep
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      
                    )
                      
                  ],
                ),

                const SizedBox(height: 8),

                // Texte
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: index <= currentStep
                        ? Colors.amber
                        : Colors.grey,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
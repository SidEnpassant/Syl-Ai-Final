import 'package:flutter/material.dart';
import 'package:sylai2/utils/theme.dart';

// class MessageInput extends StatefulWidget {
//   final Function(String) onSend;
//   final bool isLoading;

//   const MessageInput({
//     Key? key,
//     required this.onSend,
//     this.isLoading = false,
//     required TextEditingController controller,
//     required bool enabled,
//   }) : super(key: key);

//   @override
//   _MessageInputState createState() => _MessageInputState();
// }

// class _MessageInputState extends State<MessageInput> {
//   final TextEditingController _controller = TextEditingController();
//   bool _hasText = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//       setState(() {
//         _hasText = _controller.text.isNotEmpty;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _handleSend() {
//     if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
//       widget.onSend(_controller.text.trim());
//       _controller.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppTheme.cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black,
//             blurRadius: 10,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               enabled: !widget.isLoading,
//               decoration: InputDecoration(
//                 hintText: 'Type your message or paste syllabus...',
//                 hintStyle: TextStyle(color: Colors.amber),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: AppTheme.backgroundColor,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//               ),
//               style: TextStyle(color: AppTheme.textColor),
//               maxLines: 4,
//               minLines: 1,
//               textCapitalization: TextCapitalization.sentences,
//             ),
//           ),
//           const SizedBox(width: 8),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: _hasText ? AppTheme.accentColor : AppTheme.cardColor,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(24),
//                 onTap: _handleSend,
//                 child:
//                     widget.isLoading
//                         ? Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: CircularProgressIndicator(
//                             color: AppTheme.textColor,
//                             strokeWidth: 3,
//                           ),
//                         )
//                         : Icon(
//                           Icons.send,
//                           color:
//                               _hasText
//                                   ? Colors.white
//                                   : const Color.fromARGB(255, 255, 176, 176),
//                         ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isLoading;
  final bool enabled;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    });
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty &&
        !widget.isLoading &&
        widget.enabled) {
      widget.onSend(widget.controller.text.trim());
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled && !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'Type your message or paste syllabus...',
                hintStyle: TextStyle(color: Colors.amber),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              style: TextStyle(color: AppTheme.textColor),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  _hasText && widget.enabled
                      ? AppTheme.accentColor
                      : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.enabled ? _handleSend : null,
                child:
                    widget.isLoading
                        ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: AppTheme.textColor,
                            strokeWidth: 3,
                          ),
                        )
                        : Icon(
                          Icons.send,
                          color:
                              _hasText && widget.enabled
                                  ? Colors.white
                                  : const Color.fromARGB(255, 255, 176, 176),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

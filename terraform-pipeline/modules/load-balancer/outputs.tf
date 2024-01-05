output "target_groups" {
    value = aws_lb_target_group.alb_tg
}
output "lb_listener" {
    value = aws_lb_listener.alb_listener
}
output "lb" {
    value = aws_lb.alb
}
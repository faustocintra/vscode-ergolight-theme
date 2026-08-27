@extends('layouts.app')

@section('content')
@php
    namespace App\View;

    use App\Contracts\Auditable;
    use App\Models\Order as OrderModel;

    interface Renderable extends Auditable
    {
        public function renderStatus(OrderModel $order): string;
    }

    final class OrderPresenter implements Renderable
    {
        public function __construct(private readonly string $prefix = 'ORD') {}

        public function renderStatus(OrderModel $order): string
        {
            return "{$this->prefix}-{$order->id}: {$order->status}";
        }

        public function audit(): void
        {
            @trigger_error('sample', E_USER_NOTICE);
        }
    }
@endphp

<section class="orders" data-kind="sample">
    @foreach ($orders ?? [] as $order)
        <article id="order-{{ $order->id }}" @class(['is-paid' => $order->paid])>
            {{ $order->status instanceof Stringable ? $order->status : 'draft' }}
        </article>
    @endforeach
</section>
@endsection


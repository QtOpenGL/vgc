// Copyright 2017 The VGC Developers
// See the COPYRIGHT file at the top-level directory of this distribution
// and at https://github.com/vgc/vgc/blob/master/COPYRIGHT
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <vgc/dom/node.h>

#include <vgc/core/algorithm.h>

namespace vgc {
namespace dom {

Node::Node() :
    parent_(nullptr)
{

}

void Node::addChild_(NodeSharedPtr node)
{
    assert(node->parent_ == nullptr); // XXX TODO: issue an error instead of crashing.

    if (!core::contains(children_, node)) {
        children_.push_back(node);
        node->parent_ = this;
    }
}

void Node::removeAllChildren_()
{
    for (const NodeSharedPtr& node : children_) {
        node->parent_ = nullptr;
    }
    children_.clear();
}

} // namespace dom
} // namespace vgc
